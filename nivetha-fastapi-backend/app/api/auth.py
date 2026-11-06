
import logging
import re
import secrets
from typing import Any

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr, Field, field_validator
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.config import settings
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter()

customers_col = customer_db["customers"]


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=72)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        return value.strip().lower()


class CustomerRegisterRequest(BaseModel):
    full_name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(min_length=10, max_length=15)
    password: str = Field(min_length=8, max_length=72)

    @field_validator("full_name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()
        if len(value) < 2:
            raise ValueError("Full name must contain at least 2 characters.")
        return value

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        return value.strip().lower()

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, value: str) -> str:
        phone = re.sub(r"[\s()+-]", "", value)

        if not phone.isdigit() or not 10 <= len(phone) <= 15:
            raise ValueError("Enter a valid phone number.")

        return phone


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    user: dict[str, Any]


def create_user_response(user: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": str(user["_id"]),
        "full_name": user.get("full_name", user.get("name", "")),
        "email": user.get("email", ""),
        "phone": user.get("phone", ""),
        "role": "customer",
    }


def create_role_token(user_id: str, role: str) -> str:
    return create_access_token(
        data={"role": role},
        subject=user_id,
    )


def verify_staff_credentials(
    email: str,
    password: str,
    role: str,
) -> dict[str, Any] | None:
    if role == "owner":
        expected_email = settings.OWNER_EMAIL.strip().lower()
        expected_password = settings.OWNER_PASSWORD
    elif role == "admin":
        expected_email = settings.ADMIN_EMAIL.strip().lower()
        expected_password = settings.ADMIN_PASSWORD
    else:
        return None

    email_matches = secrets.compare_digest(
        email.strip().lower().encode("utf-8"),
        expected_email.encode("utf-8"),
    )
    password_matches = secrets.compare_digest(
        password.encode("utf-8"),
        expected_password.encode("utf-8"),
    )

    if not (email_matches and password_matches):
        return None

    return {
        "id": role,
        "email": expected_email,
        "role": role,
    }


async def authenticate_customer(
    email: str,
    password: str,
) -> dict[str, Any] | None:
    try:
        user = await customers_col.find_one(
            {"email": email.strip().lower()}
        )

        if not user:
            return None

        stored_password = user.get("password_hash")

        # Backward compatibility for older customer records.
        if not stored_password:
            stored_password = user.get("password", "")

        if not isinstance(stored_password, str) or not stored_password:
            return None

        if not verify_password(password, stored_password):
            return None

        return user

    except PyMongoError as exc:
        logger.exception("Customer authentication database error.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is temporarily unavailable.",
        ) from exc


async def register_customer(
    payload: CustomerRegisterRequest,
) -> dict[str, Any]:
    email = payload.email.strip().lower()

    new_user = {
        "full_name": payload.full_name,
        "name": payload.full_name,
        "email": email,
        "phone": payload.phone,
        "password_hash": hash_password(payload.password),
        "role": "customer",
    }

    try:
        result = await customers_col.insert_one(new_user)
        new_user["_id"] = result.inserted_id
        return new_user

    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email or phone number already registered.",
        ) from exc

    except PyMongoError as exc:
        logger.exception("Customer registration failed.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to register customer right now.",
        ) from exc


@router.post("/owner-login", response_model=TokenResponse)
async def owner_login(payload: LoginRequest):
    user = verify_staff_credentials(
        payload.email,
        payload.password,
        "owner",
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid owner credentials.",
        )

    return TokenResponse(
        access_token=create_role_token("owner", "owner"),
        role="owner",
        user=user,
    )


@router.post("/admin-login", response_model=TokenResponse)
async def admin_login(payload: LoginRequest):
    user = verify_staff_credentials(
        payload.email,
        payload.password,
        "admin",
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid admin credentials.",
        )

    return TokenResponse(
        access_token=create_role_token("admin", "admin"),
        role="admin",
        user=user,
    )


@router.post(
    "/customer/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
async def customer_register(payload: CustomerRegisterRequest):
    user = await register_customer(payload)

    user_id = str(user["_id"])

    return TokenResponse(
        access_token=create_role_token(user_id, "customer"),
        role="customer",
        user=create_user_response(user),
    )


@router.post("/customer/login", response_model=TokenResponse)
async def customer_login(payload: LoginRequest):
    user = await authenticate_customer(
        payload.email,
        payload.password,
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer email or password.",
        )

    user_id = str(user["_id"])

    return TokenResponse(
        access_token=create_role_token(user_id, "customer"),
        role="customer",
        user=create_user_response(user),
    )


@router.post("/login", response_model=TokenResponse)
async def unified_login(payload: LoginRequest):
    email = payload.email.strip().lower()

    for role in ("owner", "admin"):
        staff = verify_staff_credentials(
            email,
            payload.password,
            role,
        )

        if staff:
            return TokenResponse(
                access_token=create_role_token(role, role),
                role=role,
                user=staff,
            )

    customer = await authenticate_customer(
        email,
        payload.password,
    )

    if customer:
        user_id = str(customer["_id"])

        return TokenResponse(
            access_token=create_role_token(user_id, "customer"),
            role="customer",
            user=create_user_response(customer),
        )

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid email or password.",
    )
