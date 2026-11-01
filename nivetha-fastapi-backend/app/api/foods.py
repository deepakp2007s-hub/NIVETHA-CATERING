import logging
from datetime import UTC, datetime
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
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
# AUTHENTICATION
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
    model_config = ConfigDict(extra="forbid")

    name: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )

    category: str | None = Field(
        default=None,
        min_length=2,
        max_length=100,
    )

    description: str | None = Field(
        default=None,
        max_length=1000,
    )

    is_available: bool | None = None

    @field_validator("name", "category")
    @classmethod
    def validate_optional_text(
        cls,
        value: str | None,
    ) -> str | None:
        if value is None:
            return None

        value = value.strip()

        if len(value) < 2:
            raise ValueError("Must contain at least 2 non-space characters.")

        return value

    @field_validator("description")
    @classmethod
    def clean_optional_description(
        cls,
        value: str | None,
    ) -> str | None:
        return value.strip() if value is not None else None


# =====================================================
# SERIALIZATION
# =====================================================


def serialize_food(food: dict[str, Any]) -> dict[str, Any]:
    created_at = food.get("created_at")
    updated_at = food.get("updated_at")

    return {
        "id": str(food["_id"]),
        "name": food.get("name", ""),
        "category": food.get("category", ""),
        "description": food.get("description", ""),
        "is_available": food.get("is_available", True),
        "created_at": (
            created_at.isoformat() if isinstance(created_at, datetime) else created_at
        ),
        "updated_at": (
            updated_at.isoformat() if isinstance(updated_at, datetime) else updated_at
        ),
    }


# =====================================================
# CUSTOMER: GET AVAILABLE FOODS
# =====================================================


@router.get("/")
def get_foods():
    try:
        items = list(
            foods_collection.find({"is_available": {"$ne": False}})
            .sort("created_at", -1)
            .limit(500)
        )

        return {
            "success": True,
            "count": len(items),
            "foods": [serialize_food(item) for item in items],
        }

    except PyMongoError as exc:
        logger.exception("Unable to retrieve foods.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load foods.",
        ) from exc


# =====================================================
# CUSTOMER: GET SINGLE AVAILABLE FOOD
# =====================================================


@router.get("/{food_id}")
def get_food(food_id: str):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID.",
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
                detail="Food not found.",
            )

        return {
            "success": True,
            "food": serialize_food(item),
        }

    except HTTPException:
        raise

    except PyMongoError as exc:
        logger.exception("Unable to retrieve food.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load food.",
        ) from exc


# =====================================================
# OWNER / ADMIN: ADD FOOD
# =====================================================


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
)
def add_food(
    data: FoodCreate,
    _: dict = Depends(require_owner_or_admin),
):
    now = datetime.now(UTC)

    food = {
        "name": data.name,
        "category": data.category,
        "description": data.description,
        "is_available": data.is_available,
        "created_at": now,
        "updated_at": now,
    }

    try:
        result = foods_collection.insert_one(food)

        food["_id"] = result.inserted_id

        logger.info(
            "Food created successfully: %s",
            result.inserted_id,
        )

        return {
            "success": True,
            "message": "Food added successfully.",
            "food": serialize_food(food),
        }

    except PyMongoError as exc:
        logger.exception("Unable to add food.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to add food.",
        ) from exc


# =====================================================
# OWNER / ADMIN: EDIT FOOD
# =====================================================


@router.patch("/{food_id}")
def edit_food(
    food_id: str,
    data: FoodUpdate,
    _: dict = Depends(require_owner_or_admin),
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
            detail="Provide fields to update.",
        )

    if any(value is None for value in updates.values()):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Food fields cannot be null.",
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
                detail="Food not found.",
            )

        item = foods_collection.find_one({"_id": ObjectId(food_id)})

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found after update.",
            )

        return {
            "success": True,
            "message": "Food updated successfully.",
            "food": serialize_food(item),
        }

    except HTTPException:
        raise

    except PyMongoError as exc:
        logger.exception("Unable to update food.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to edit food.",
        ) from exc


# =====================================================
# OWNER / ADMIN: DELETE FOOD
# =====================================================


@router.delete("/{food_id}")
def delete_food(
    food_id: str,
    _: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID.",
        )

    try:
        result = foods_collection.delete_one({"_id": ObjectId(food_id)})

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found.",
            )

        logger.info(
            "Food deleted successfully: %s",
            food_id,
        )

        return {
            "success": True,
            "message": "Food deleted successfully.",
        }

    except HTTPException:
        raise

    except PyMongoError as exc:
        logger.exception("Unable to delete food.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to delete food.",
        ) from exc
