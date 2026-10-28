
import logging
from datetime import datetime, timezone
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field, field_validator
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import owner_db


logger = logging.getLogger(__name__)

router = APIRouter(prefix="/foods", tags=["Food Management"])
bearer_scheme = HTTPBearer(auto_error=False)


# -------------------- AUTHENTICATION --------------------

def require_owner(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in with an owner account.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid access token.",
            )

        if payload.get("role") != "owner":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Owner account required.",
            )

        owner_id = payload.get("sub")
        if not owner_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid owner token.",
            )

        return str(owner_id)

    except HTTPException:
        raise
    except (jwt.InvalidTokenError, ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )


# -------------------- REQUEST MODELS --------------------

class FoodCreate(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    category: str = Field(min_length=2, max_length=100)
    description: str = Field(default="", max_length=1000)
    is_available: bool = True

    @field_validator("name", "category")
    @classmethod
    def validate_required_text(cls, value: str) -> str:
        value = value.strip()
        if len(value) < 2:
            raise ValueError("Must contain at least 2 non-space characters.")
        return value

    @field_validator("description")
    @classmethod
    def clean_description(cls, value: str) -> str:
        return value.strip()


class FoodUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=150)
    category: str | None = Field(default=None, min_length=2, max_length=100)
    description: str | None = Field(default=None, max_length=1000)
    is_available: bool | None = None

    @field_validator("name", "category")
    @classmethod
    def validate_optional_text(cls, value: str | None) -> str | None:
        if value is None:
            return value
        value = value.strip()
        if len(value) < 2:
            raise ValueError("Must contain at least 2 non-space characters.")
        return value

    @field_validator("description")
    @classmethod
    def clean_optional_description(cls, value: str | None) -> str | None:
        return value.strip() if value is not None else None


# -------------------- RESPONSE SERIALIZATION --------------------

def serialize_food(food: dict[str, Any]) -> dict[str, Any]:
    created_at = food.get("created_at")
    updated_at = food.get("updated_at")

    return {
        "id": str(food["_id"]),
        "name": food.get("name", ""),
        "category": food.get("category", ""),
        "description": food.get("description", ""),
        "is_available": food.get("is_available", True),
        "created_at": created_at.isoformat() if isinstance(created_at, datetime) else created_at,
        "updated_at": updated_at.isoformat() if isinstance(updated_at, datetime) else updated_at,
    }


# -------------------- LIST FOODS --------------------

@router.get("/")
def get_foods():
    """Read-only food list; no owner token required."""
    try:
        foods = list(
            owner_db["foods"]
            .find()
            .sort("created_at", -1)
            .limit(500)
        )

        return {
            "success": True,
            "count": len(foods),
            "foods": [serialize_food(food) for food in foods],
        }

    except PyMongoError:
        logger.exception("Unable to retrieve foods.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load foods.",
        )


# -------------------- GET ONE FOOD --------------------

@router.get("/{food_id}")
def get_food(food_id: str):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID.",
        )

    try:
        food = owner_db["foods"].find_one({"_id": ObjectId(food_id)})

        if food is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found.",
            )

        return {"success": True, "food": serialize_food(food)}

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Unable to retrieve food.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load food.",
        )


# -------------------- ADD FOOD: OWNER ONLY --------------------

@router.post("/", status_code=status.HTTP_201_CREATED)
def add_food(
    data: FoodCreate,
    owner_id: str = Depends(require_owner),
):
    now = datetime.now(timezone.utc)

    food = {
        "name": data.name,
        "category": data.category,
        "description": data.description,
        "is_available": data.is_available,
        "created_at": now,
        "updated_at": now,
    }

    try:
        result = owner_db["foods"].insert_one(food)
        food["_id"] = result.inserted_id

        logger.info("Food created by authenticated owner.")

        return {
            "success": True,
            "message": "Food added successfully.",
            "food": serialize_food(food),
        }

    except PyMongoError:
        logger.exception("Unable to add food.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to add food.",
        )


# -------------------- EDIT FOOD: OWNER ONLY --------------------

@router.patch("/{food_id}")
def edit_food(
    food_id: str,
    data: FoodUpdate,
    owner_id: str = Depends(require_owner),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID.",
        )

    updates = data.model_dump(exclude_unset=True)

    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide at least one field to update.",
        )

    try:
        collection = owner_db["foods"]
        food_object_id = ObjectId(food_id)

        result = collection.update_one(
            {"_id": food_object_id},
            {"$set": {
                **updates,
                "updated_at": datetime.now(timezone.utc),
            }},
        )

        if result.matched_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found.",
            )

        updated_food = collection.find_one({"_id": food_object_id})

        return {
            "success": True,
            "message": "Food updated successfully.",
            "food": serialize_food(updated_food),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Unable to update food.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to edit food.",
        )


# -------------------- DELETE FOOD: OWNER ONLY --------------------

@router.delete("/{food_id}")
def delete_food(
    food_id: str,
    owner_id: str = Depends(require_owner),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID.",
        )

    try:
        result = owner_db["foods"].delete_one(
            {"_id": ObjectId(food_id)}
        )

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found.",
            )

        return {
            "success": True,
            "message": "Food deleted successfully.",
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Unable to delete food.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to delete food.",
        )
