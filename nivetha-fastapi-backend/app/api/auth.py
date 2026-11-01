
import hashlib
import logging
from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, Request, status
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
from pymongo import ReturnDocument
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.config import settings
from app.core.security import create_access_token, hash_password, verify_password
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])

customers = customer_db["customers"]
login_rate_limits = customer_db["login_rate_limits"]


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
        cleaned = "".join(char for char in value if char not in " -()+")
        if not cleaned.isdigit() or not 10 <= len(cleaned) <= 15:
            raise ValueError("Enter a valid phone number.")
        return cleaned


class LoginRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class OwnerLoginRequest(LoginRequest):
    pass


class AdminLoginRequest(LoginRequest):
    pass


def normalize_email(email: str) -> str:
    return email.strip().lower()


def customer_response(customer: dict) -> dict:
    return {
        "id": str(customer["_id"]),
        "name": customer.get("name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
    }


def enforce_login_rate_limit(
    request: Request,
    role: str,
    identity: str,
) -> None:
    """Atomically increment a shared MongoDB fixed-window counter."""

    now = datetime.now(UTC)
    window_seconds = settings.LOGIN_RATE_LIMIT_WINDOW_SECONDS
    max_attempts = settings.LOGIN_RATE_LIMIT_MAX_ATTEMPTS

    if window_seconds <= 0 or max_attempts <= 0:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Login protection is not configured correctly.",
        )

    client_ip = request.client.host if request.client else "unknown"
    identity_digest = hashlib.sha256(
        f"{role}:{identity}:{client_ip}".encode()
    ).hexdigest()

    bucket = int(now.timestamp()) // window_seconds
    document_id = f"{identity_digest}:{bucket}"

    expires_at = datetime.fromtimestamp(
        (bucket + 1) * window_seconds,
        tz=UTC,
    )

    try:
        result = login_rate_limits.find_one_and_update(
            {"_id": document_id},
            {
                "$inc": {"attempts": 1},
                "$setOnInsert": {
                    "expires_at": expires_at,
                    "created_at": now,
                    "role": role,
                },
            },
            upsert=True,
            return_document=ReturnDocument.AFTER,
        )

        if result is None:
            raise PyMongoError(
                "Rate-limit counter update returned no document."
            )

    except DuplicateKeyError:
        try:
            result = login_rate_limits.find_one_and_update(
                {"_id": document_id},
                {"$inc": {"attempts": 1}},
                upsert=False,
                return_document=ReturnDocument.AFTER,
            )
        except PyMongoError as exc:
            logger.exception("Login rate limiter recovery failed.")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Login protection is temporarily unavailable.",
            ) from exc

        if result is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Login protection is temporarily unavailable.",
            ) from None

    except PyMongoError as exc:
        logger.exception("Login rate limiter database operation failed.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Login protection is temporarily unavailable.",
        ) from exc

    if result["attempts"] > max_attempts:
        remaining = window_seconds - (
            int(now.timestamp()) % window_seconds
        )

        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Please try again later.",
            headers={"Retry-After": str(remaining)},
        )


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_customer(data: RegisterRequest):
    email = normalize_email(str(data.email))
    now = datetime.now(UTC)

    customer = {
        "name": data.name,
        "email": email,
        "phone": data.phone,
        "password_hash": hash_password(data.password),
        "created_at": now,
        "updated_at": now,
    }

    try:
        existing = customers.find_one(
            {"$or": [{"email": email}, {"phone": data.phone}]},
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


@router.post("/login")
def login_customer(data: LoginRequest, request: Request):
    email = normalize_email(str(data.email))
    enforce_login_rate_limit(request, "customer", email)

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
            {"$set": {"updated_at": datetime.now(UTC)}},
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


def _login_staff(
    request: Request,
    email: str,
    password: str,
    role: str,
) -> dict:
    normalized_email = normalize_email(email)

    if role == "owner":
        configured_email = normalize_email(settings.OWNER_EMAIL)
        configured_hash = settings.owner_password_hash_value
    elif role == "admin":
        configured_email = normalize_email(settings.ADMIN_EMAIL)
        configured_hash = settings.admin_password_hash_value
    else:
        raise ValueError("Unsupported staff role.")

    if not configured_email or not configured_hash:
        logger.error("%s login credentials are not configured.", role)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"{role.capitalize()} authentication is not configured.",
        )

    enforce_login_rate_limit(request, role, normalized_email)

    email_matches = normalized_email == configured_email
    password_matches = verify_password(password, configured_hash)

    if not email_matches or not password_matches:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid {role} email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token(subject=role, role=role)

    logger.info("%s login successful.", role)

    return {
        "success": True,
        "message": f"{role.capitalize()} login successful.",
        "access_token": token,
        "token_type": "bearer",
        role: {
            "id": role,
            "email": configured_email,
            "role": role,
        },
    }


@router.post("/owner/login")
def login_owner(data: OwnerLoginRequest, request: Request):
    return _login_staff(
        request=request,
        email=str(data.email),
        password=data.password,
        role="owner",
    )


@router.post("/admin/login")
def login_admin(data: AdminLoginRequest, request: Request):
    return _login_staff(
        request=request,
        email=str(data.email),
        password=data.password,
        role="admin",
    )
