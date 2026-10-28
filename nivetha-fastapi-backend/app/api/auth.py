
import re

from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
)
from app.db.mongo import customer_db


router = APIRouter(prefix="/auth", tags=["Customer Authentication"])


class RegisterRequest(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(min_length=10, max_length=15)
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


def normalize_email(email: str) -> str:
    return email.strip().lower()


def validate_phone(phone: str) -> str:
    cleaned = re.sub(r"[\s\-()+]", "", phone)

    if not cleaned.isdigit() or not 10 <= len(cleaned) <= 15:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Enter a valid phone number.",
        )

    return cleaned


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_customer(data: RegisterRequest):
    email = normalize_email(str(data.email))
    phone = validate_phone(data.phone)

    customers = customer_db["customers"]

    try:
        if customers.find_one(
            {"$or": [{"email": email}, {"phone": phone}]},
            {"_id": 1},
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email or phone number is already registered.",
            )

        customer = {
            "name": data.name.strip(),
            "email": email,
            "phone": phone,
            "password_hash": hash_password(data.password),
            "created_at": datetime.now(timezone.utc),
            "updated_at": datetime.now(timezone.utc),
        }

        result = customers.insert_one(customer)
        customer_id = str(result.inserted_id)

        token = create_access_token(
            subject=customer_id,
            role="customer",
        )

        return {
            "success": True,
            "message": "Customer registered successfully",
            "access_token": token,
            "token_type": "bearer",
            "customer": {
                "id": customer_id,
                "name": customer["name"],
                "email": customer["email"],
                "phone": customer["phone"],
            },
        }

    except DuplicateKeyError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email or phone number is already registered.",
        )
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is temporarily unavailable.",
        )


@router.post("/login")
def login_customer(data: LoginRequest):
    email = normalize_email(str(data.email))
    customers = customer_db["customers"]

    try:
        customer = customers.find_one({"email": email})

        if not customer or not verify_password(
            data.password,
            customer.get("password_hash", ""),
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        customer_id = str(customer["_id"])

        token = create_access_token(
            subject=customer_id,
            role="customer",
        )

        customers.update_one(
            {"_id": customer["_id"]},
            {"$set": {"updated_at": datetime.now(timezone.utc)}},
        )

        return {
            "success": True,
            "message": "Login successful",
            "access_token": token,
            "token_type": "bearer",
            "customer": {
                "id": customer_id,
                "name": customer.get("name", ""),
                "email": customer.get("email", ""),
                "phone": customer.get("phone", ""),
            },
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is temporarily unavailable.",
        )
