
from datetime import datetime, timezone

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


router = APIRouter(prefix="/profile", tags=["Customer Profile"])
bearer_scheme = HTTPBearer(auto_error=False)


class ProfileUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=100)
    phone: str | None = Field(default=None, min_length=10, max_length=15)


def get_current_customer(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to access your profile.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if payload.get("role") != "customer":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customer account required.",
            )

        customer_id = payload.get("sub")

        if not customer_id or not ObjectId.is_valid(customer_id):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid access token.",
            )

    except HTTPException:
        raise
    except (jwt.InvalidTokenError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        customer = customer_db["customers"].find_one(
            {"_id": ObjectId(customer_id)}
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer profile not found.",
            )

        return customer

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to access the customer profile.",
        )


def serialize_customer(customer: dict) -> dict:
    return {
        "id": str(customer["_id"]),
        "name": customer.get("name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
        "created_at": customer.get("created_at"),
        "updated_at": customer.get("updated_at"),
    }


@router.get("/me")
def get_my_profile(
    customer: dict = Depends(get_current_customer),
):
    return {
        "success": True,
        "customer": serialize_customer(customer),
    }


@router.patch("/me")
def update_my_profile(
    data: ProfileUpdate,
    customer: dict = Depends(get_current_customer),
):
    updates = {}

    if data.name is not None:
        name = data.name.strip()
        if len(name) < 2:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Name must contain at least 2 characters.",
            )
        updates["name"] = name

    if data.phone is not None:
        phone = data.phone.strip()
        if not phone.isdigit() or not 10 <= len(phone) <= 15:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Enter a valid phone number using digits only.",
            )

        existing = customer_db["customers"].find_one(
            {
                "phone": phone,
                "_id": {"$ne": customer["_id"]},
            },
            {"_id": 1},
        )

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This phone number is already registered.",
            )

        updates["phone"] = phone

    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide at least one profile field to update.",
        )

    updates["updated_at"] = datetime.now(timezone.utc)

    try:
        customer_db["customers"].update_one(
            {"_id": customer["_id"]},
            {"$set": updates},
        )

        updated_customer = customer_db["customers"].find_one(
            {"_id": customer["_id"]}
        )

        return {
            "success": True,
            "message": "Profile updated successfully",
            "customer": serialize_customer(updated_customer),
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update the profile right now.",
        )
