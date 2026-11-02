import html
import logging
from datetime import UTC, datetime
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, field_validator
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/foods",
    tags=["Food Management"],
)

bearer_scheme = HTTPBearer(auto_error=False)

foods_collection = customer_db["foods"]


# =====================================================
# AUTHENTICATION DEPENDENCY
# =====================================================


def require_owner_or_admin(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Owner or Admin authorization required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise ValueError("Invalid token payload.")

        role = payload.get("role")
        subject = payload.get("sub")

        if role not in {"owner", "admin"}:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Owner or Admin access required.",
            )

        if subject != role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid staff account token.",
            )

        return {
            "id": role,
            "role": role,
        }

    except HTTPException:
        raise
    except (
        jwt.InvalidTokenError,
        ValueError,
        TypeError,
        KeyError,
    ) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


# =====================================================
# REQUEST MODELS
# =====================================================


class FoodCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str = Field(min_length=2, max_length=150)
    category: str = Field(min_length=2, max_length=100)
    description: str = Field(default="", max_length=1000)
    image_url: str = Field(default="", max_length=500)
    is_veg: bool = True
    is_available: bool = True

    @field_validator("name", "category")
    @classmethod
    def validate_required_text(cls, value: str) -> str:
        cleaned = html.escape(value.strip())
        if len(cleaned) < 2:
            raise ValueError("Must contain at least 2 valid characters.")
        return cleaned

    @field_validator("description", "image_url")
    @classmethod
    def clean_text_fields(cls, value: str) -> str:
        return html.escape(value.strip())


class FoodUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str | None = Field(default=None, min_length=2, max_length=150)
    category: str | None = Field(default=None, min_length=2, max_length=100)
    description: str | None = Field(default=None, max_length=1000)
    image_url: str | None = Field(default=None, max_length=500)
    is_veg: bool | None = None
    is_available: bool | None = None

    @field_validator("name", "category")
    @classmethod
    def validate_optional_text(cls, value: str | None) -> str | None:
        if value is None:
            return None
        cleaned = html.escape(value.strip())
        if len(cleaned) < 2:
            raise ValueError("Must contain at least 2 valid characters.")
        return cleaned

    @field_validator("description", "image_url")
    @classmethod
    def clean_optional_text(cls, value: str | None) -> str | None:
        return html.escape(value.strip()) if value is not None else None


# =====================================================
# SERIALIZATION HELPER
# =====================================================


def serialize_food(food: dict[str, Any]) -> dict[str, Any]:
    created_at = food.get("created_at")
    updated_at = food.get("updated_at")

    return {
        "id": str(food["_id"]),
        "name": food.get("name", ""),
        "category": food.get("category", ""),
        "description": food.get("description", ""),
        "image_url": food.get("image_url", ""),
        "is_veg": food.get("is_veg", True),
        "is_available": food.get("is_available", True),
        "created_at": (
            created_at.isoformat() if isinstance(created_at, datetime) else created_at
        ),
        "updated_at": (
            updated_at.isoformat() if isinstance(updated_at, datetime) else updated_at
        ),
    }


# =====================================================
# ENDPOINTS
# =====================================================


@router.get("/")
def get_foods(
    category: str | None = Query(None, description="Filter foods by category"),
    search: str | None = Query(None, description="Search foods by name"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=300),
):
    try:
        query: dict[str, Any] = {"is_available": {"$ne": False}}

        if category and category.strip():
            query["category"] = category.strip()

        if search and search.strip():
            query["name"] = {"$regex": search.strip(), "$options": "i"}

        total = foods_collection.count_documents(query)
        items = list(
            foods_collection.find(query)
            .sort("name", 1)
            .skip(skip)
            .limit(limit)
        )

        return {
            "success": True,
            "total": total,
            "count": len(items),
            "foods": [serialize_food(item) for item in items],
        }

    except PyMongoError as exc:
        logger.exception("Unable to retrieve foods.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load foods right now.",
        ) from exc


@router.get("/{food_id}")
def get_food(food_id: str):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID format.",
        )

    try:
        item = foods_collection.find_one(
            {
                "_id": ObjectId(food_id),
                "is_available": {"$ne": False},
            }
        )

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food item not found or currently unavailable.",
            )

        return {
            "success": True,
            "food": serialize_food(item),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to retrieve food detail.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load food item.",
        ) from exc


@router.post("/", status_code=status.HTTP_201_CREATED)
def add_food(
    data: FoodCreate,
    _: dict = Depends(require_owner_or_admin),
):
    now = datetime.now(UTC)

    food = {
        "name": data.name,
        "category": data.category,
        "description": data.description,
        "image_url": data.image_url,
        "is_veg": data.is_veg,
        "is_available": data.is_available,
        "created_at": now,
        "updated_at": now,
    }

    try:
        result = foods_collection.insert_one(food)
        food["_id"] = result.inserted_id

        logger.info("Food item created: %s", result.inserted_id)

        return {
            "success": True,
            "message": "Food added successfully.",
            "food": serialize_food(food),
        }

    except PyMongoError as exc:
        logger.exception("Unable to add food item.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to add food item right now.",
        ) from exc


@router.patch("/{food_id}")
def edit_food(
    food_id: str,
    data: FoodUpdate,
    _: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID format.",
        )

    updates = data.model_dump(exclude_unset=True)

    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide at least one field to update.",
        )

    updates["updated_at"] = datetime.now(UTC)

    try:
        result = foods_collection.update_one(
            {"_id": ObjectId(food_id)},
            {"$set": updates},
        )

        if result.matched_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food item not found.",
            )

        item = foods_collection.find_one({"_id": ObjectId(food_id)})

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food item not found after update.",
            )

        return {
            "success": True,
            "message": "Food updated successfully.",
            "food": serialize_food(item),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to update food item.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to edit food item.",
        ) from exc


@router.delete("/{food_id}")
def delete_food(
    food_id: str,
    _: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID format.",
        )

    try:
        result = foods_collection.delete_one({"_id": ObjectId(food_id)})

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food item not found.",
            )

        logger.info("Food deleted: %s", food_id)

        return {
            "success": True,
            "message": "Food item deleted successfully.",
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to delete food item.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to delete food item.",
        ) from exc