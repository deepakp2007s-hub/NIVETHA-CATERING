
import logging
from datetime import datetime, timezone

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, field_validator
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/profile",
    tags=["Customer Profile"],
)

bearer_scheme = HTTPBearer(auto_error=False)
customers_collection = customer_db["customers"]


class ProfileUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str | None = Field(default=None, min_length=2, max_length=100)
    phone: str | None = Field(default=None, min_length=10, max_length=15)

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str | None) -> str | None:
        if value is None:
            return value

        value = value.strip()

        if len(value) < 2:
            raise ValueError("Name must contain at least 2 characters.")

        return value

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, value: str | None) -> str | None:
        if value is None:
            return value

        value = value.strip()

        if not value.isdigit() or not 10 <= len(value) <= 15:
            raise ValueError(
                "Enter a valid phone number using digits only."
            )

        return value


def get_authenticated_payload(
    credentials: HTTPAuthorizationCredentials | None,
) -> dict:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to access this resource.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise ValueError("Invalid token payload.")

        return payload

    except HTTPException:
        raise
    except (jwt.InvalidTokenError, ValueError, TypeError, KeyError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


def get_current_customer(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    payload = get_authenticated_payload(credentials)

    if payload.get("role") != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Customer account required.",
        )

    customer_id = payload.get("sub")

    if not isinstance(customer_id, str) or not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer ID in access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        customer = customers_collection.find_one(
            {"_id": ObjectId(customer_id)}
        )

        if customer is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer profile not found.",
            )

        return customer

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Error retrieving customer profile.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to access the customer profile.",
        ) from exc


def get_current_owner(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    payload = get_authenticated_payload(credentials)

    # Match this to the claims created by the Owner login endpoint.
    if payload.get("role") != "owner" or payload.get("sub") != "owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner account required.",
        )

    return payload


def serialize_customer(customer: dict) -> dict:
    created_at = customer.get("created_at")
    updated_at = customer.get("updated_at")

    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    if isinstance(updated_at, datetime):
        updated_at = updated_at.isoformat()

    return {
        "id": str(customer["_id"]),
        "name": customer.get("name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
        "created_at": created_at,
        "updated_at": updated_at,
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
    updates = data.model_dump(exclude_unset=True)

    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide at least one profile field to update.",
        )

    if any(value is None for value in updates.values()):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Profile fields cannot be null.",
        )

    try:
        if "phone" in updates:
            existing = customers_collection.find_one(
                {
                    "phone": updates["phone"],
                    "_id": {"$ne": customer["_id"]},
                },
                {"_id": 1},
            )

            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="This phone number is already registered.",
                )

        updates["updated_at"] = datetime.now(timezone.utc)

        customers_collection.update_one(
            {"_id": customer["_id"]},
            {"$set": updates},
        )

        updated_customer = customers_collection.find_one(
            {"_id": customer["_id"]}
        )

        if updated_customer is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer profile not found after update.",
            )

        return {
            "success": True,
            "message": "Profile updated successfully.",
            "customer": serialize_customer(updated_customer),
        }

    except HTTPException:
        raise
    except DuplicateKeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This phone number is already registered.",
        ) from exc
    except PyMongoError as exc:
        logger.exception("Error updating customer profile.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update the profile right now.",
        ) from exc
