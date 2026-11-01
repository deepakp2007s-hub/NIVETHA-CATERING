
import hmac
import logging
import re
from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, status
from pydantic import (
    BaseModel,
    ConfigDict,
    EmailStr,
    Field,
    field_validator,
)
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.config import settings
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

customers = customer_db["customers"]


# =====================================================
# REQUEST MODELS
# =====================================================


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
    def validate_phone(cls, value: str) -> str:
        cleaned = re.sub(r"[\s\-()+]", "", value)
        if not cleaned.isdigit() or not 10 <= len(cleaned) <= 15:
            raise ValueError("Enter a valid phone number.")
        return cleaned


class LoginRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


# =====================================================
# COMMON HELPERS
# =====================================================


def normalize_email(email: str) -> str:
    return email.strip().lower()


def customer_response(customer: dict) -> dict:
    return {
        "id": str(customer["_id"]),
        "name": customer.get("name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
    }


def configured_credentials(role: str) -> tuple[str, str]:
    if role == "owner":
        email = normalize_email(settings.OWNER_EMAIL)
        password = settings.owner_password_value
    elif role == "admin":
        email = normalize_email(settings.ADMIN_EMAIL)
        password = settings.admin_password_value
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid authentication role.",
        )

    if not email or not password:
        logger.error("%s authentication configuration is missing.", role)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"{role.capitalize()} authentication is not configured.",
        )

    return email, password


def authenticate_configured_user(
    data: LoginRequest,
    role: str,
) -> dict:
    configured_email, configured_password = configured_credentials(role)

    supplied_email = normalize_email(str(data.email))

    email_matches = hmac.compare_digest(
        supplied_email,
        configured_email,
    )
    password_matches = hmac.compare_digest(
        data.password,
        configured_password,
    )

    if not email_matches or not password_matches:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token(subject=role, role=role)

    logger.info("%s login successful.", role)

    return {
        "success": True,
        "message": f"{role.capitalize()} login successful.",
        "access_token": token,
        "token_type": "bearer",  # nosec B105
        role: {
            "id": role,
            "email": configured_email,
            "role": role,
        },
    }


# =====================================================
# CUSTOMER REGISTER
# =====================================================


@router.post(
    "/register",
    status_code=status.HTTP_201_CREATED,
)
def register_customer(data: RegisterRequest):
    email = normalize_email(str(data.email))
    phone = data.phone
    now = datetime.now(UTC)

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
            {
                "$or": [
                    {"email": email},
                    {"phone": phone},
                ]
            },
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
            "token_type": "bearer",  # nosec B105
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


# =====================================================
# CUSTOMER LOGIN
# =====================================================


@router.post("/login")
def login_customer(data: LoginRequest):
    email = normalize_email(str(data.email))

    try:
        customer = customers.find_one({"email": email})

        if customer is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        password_hash_value = customer.get("password_hash", "")

        if not password_hash_value or not verify_password(
            data.password,
            password_hash_value,
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

        try:
            customers.update_one(
                {"_id": customer["_id"]},
                {"$set": {"updated_at": datetime.now(UTC)}},
            )
        except PyMongoError:
            logger.warning(
                "Could not update customer login timestamp.",
                exc_info=True,
            )

        logger.info("Customer login successful.")

        return {
            "success": True,
            "message": "Login successful.",
            "access_token": token,
            "token_type": "bearer",  # nosec B105
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


# =====================================================
# OWNER LOGIN
# =====================================================


@router.post("/owner/login")
def login_owner(data: LoginRequest):
    return authenticate_configured_user(data=data, role="owner")


# =====================================================
# ADMIN LOGIN
# =====================================================


@router.post("/admin/login")
def login_admin(data: LoginRequest):
    return authenticate_configured_user(data=data, role="admin")
