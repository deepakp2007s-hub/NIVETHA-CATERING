
import logging
import os
import re
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
)
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

customers = customer_db["customers"]


# -------------------- REQUEST MODELS --------------------

class RegisterRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(min_length=10, max_length=15)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        value = value.strip()
        if len(value) < 2:
            raise ValueError("Name must contain at least 2 characters.")
        return value

    @field_validator("phone")
    @classmethod
    def validate_phone_field(cls, value: str) -> str:
        cleaned = re.sub(r"[\s\-()+]", "", value)

        if not cleaned.isdigit() or not 10 <= len(cleaned) <= 15:
            raise ValueError("Enter a valid phone number.")

        return cleaned


class LoginRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class OwnerLoginRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


# -------------------- HELPERS --------------------

def normalize_email(email: str) -> str:
    return email.strip().lower()


def customer_response(customer: dict) -> dict:
    return {
        "id": str(customer["_id"]),
        "name": customer.get("name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
    }


# -------------------- CUSTOMER REGISTER --------------------

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_customer(data: RegisterRequest):
    email = normalize_email(str(data.email))
    phone = data.phone
    now = datetime.now(timezone.utc)

    customer = {
        "name": data.name,
        "email": email,
        "phone": phone,
        "password_hash": hash_password(data.password),
        "created_at": now,
        "updated_at": now,
    }

    try:
        existing = customers.find_one(
            {"$or": [{"email": email}, {"phone": phone}]},
            {"_id": 1},
        )

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email or phone number is already registered.",
            )

        result = customers.insert_one(customer)
        customer["_id"] = result.inserted_id

        token = create_access_token(
            subject=str(result.inserted_id),
            role="customer",
        )

        logger.info("Customer registered successfully.")

        return {
            "success": True,
            "message": "Customer registered successfully.",
            "access_token": token,
            "token_type": "bearer",
            "customer": customer_response(customer),
        }

    except HTTPException:
        raise
    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email or phone number is already registered.",
        ) from exc
    except PyMongoError as exc:
        logger.exception("Database error during customer registration.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is temporarily unavailable.",
        ) from exc


# -------------------- CUSTOMER LOGIN --------------------

@router.post("/login")
def login_customer(data: LoginRequest):
    email = normalize_email(str(data.email))

    try:
        customer = customers.find_one({"email": email})

        if customer is None or not verify_password(
            data.password,
            customer.get("password_hash", ""),
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        token = create_access_token(
            subject=str(customer["_id"]),
            role="customer",
        )

        customers.update_one(
            {"_id": customer["_id"]},
            {"$set": {"updated_at": datetime.now(timezone.utc)}},
        )

        logger.info("Customer login successful.")

        return {
            "success": True,
            "message": "Login successful.",
            "access_token": token,
            "token_type": "bearer",
            "customer": customer_response(customer),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Database error during customer login.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is temporarily unavailable.",
        ) from exc


# -------------------- OWNER LOGIN --------------------

@router.post("/owner/login")
def login_owner(data: OwnerLoginRequest):
    """
    Owner credentials are configured on the backend only.
    OWNER_PASSWORD_HASH must contain a password hash,
    never the plain-text password.
    """
    owner_email = normalize_email(os.getenv("OWNER_EMAIL", ""))
    owner_password_hash = os.getenv("OWNER_PASSWORD_HASH", "").strip()

    if not owner_email or not owner_password_hash:
        logger.error("Owner login credentials are not configured.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Owner authentication is not configured.",
        )

    supplied_email = normalize_email(str(data.email))

    try:
        email_matches = supplied_email == owner_email
        password_matches = verify_password(
            data.password,
            owner_password_hash,
        )

        if not email_matches or not password_matches:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid owner email or password.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        token = create_access_token(
            subject="owner",
            role="owner",
        )

        logger.info("Owner login successful.")

        return {
            "success": True,
            "message": "Owner login successful.",
            "access_token": token,
            "token_type": "bearer",
            "owner": {
                "id": "owner",
                "email": owner_email,
                "role": "owner",
            },
        }

    except HTTPException:
        raise
    except (ValueError, TypeError) as exc:
        logger.exception("Owner authentication configuration is invalid.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Owner authentication configuration is invalid.",
        ) from exc
