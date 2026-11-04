
import logging
from datetime import datetime, timezone
from enum import Enum
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, ConfigDict, Field
from pymongo.errors import DuplicateKeyError, PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(tags=["Foods"])

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

foods = customer_db["foods"]


# ---------------------------------------------------------------------------
# ENUMS
# ---------------------------------------------------------------------------

class FoodCategory(str, Enum):
    BREAKFAST = "Breakfast"
    LUNCH = "Lunch"
    DINNER = "Dinner"
    SWEETS = "Sweets"


# ---------------------------------------------------------------------------
# SCHEMAS
# ---------------------------------------------------------------------------

class FoodCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str = Field(min_length=2, max_length=150)
    category: FoodCategory
    description: Optional[str] = Field(default=None, max_length=1000)
    is_available: bool = True
    image_url: Optional[str] = Field(default=None, max_length=2000)
    is_vegetarian: bool = True


class FoodUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: Optional[str] = Field(default=None, min_length=2, max_length=150)
    category: Optional[FoodCategory] = None
    description: Optional[str] = Field(default=None, max_length=1000)
    is_available: Optional[bool] = None
    image_url: Optional[str] = Field(default=None, max_length=2000)
    is_vegetarian: Optional[bool] = None


class FoodAvailabilityUpdate(BaseModel):
    is_available: bool


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

async def get_token_payload(
    token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = decode_access_token(token)

        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        return payload

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )


async def require_owner_or_admin(
    payload: dict = Depends(get_token_payload),
) -> dict:
    if payload.get("role") not in {"owner", "admin"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner or admin access required",
        )

    return payload


# ---------------------------------------------------------------------------
# SERIALIZER
# ---------------------------------------------------------------------------

def serialize_food(food: dict) -> dict:
    if not food:
        return {}

    created_at = food.get("created_at")
    updated_at = food.get("updated_at")

    return {
        "id": str(food["_id"]),
        "name": food.get("name", ""),
        "category": food.get("category", ""),
        "description": food.get("description"),
        "is_available": food.get("is_available", True),
        "image_url": food.get("image_url"),
        "is_vegetarian": food.get("is_vegetarian", True),
        "created_at": (
            created_at.isoformat()
            if isinstance(created_at, datetime)
            else created_at
        ),
        "updated_at": (
            updated_at.isoformat()
            if isinstance(updated_at, datetime)
            else updated_at
        ),
    }


# ---------------------------------------------------------------------------
# CREATE FOOD
# POST /api/v1/foods/
# ---------------------------------------------------------------------------

@router.post("/", status_code=status.HTTP_201_CREATED)
async def add_food_item(
    data: FoodCreate,
    user: dict = Depends(require_owner_or_admin),
):
    try:
        food_name = data.name.strip()

        if len(food_name) < 2:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Food name must contain at least 2 characters",
            )

        existing_food = await foods.find_one({
            "name": {
                "$regex": f"^{food_name}$",
                "$options": "i",
            },
            "category": data.category.value,
        })

        if existing_food:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This food already exists in this category",
            )

        now = datetime.now(timezone.utc)

        food_document = {
            "name": food_name,
            "category": data.category.value,
            "description": (
                data.description.strip()
                if data.description
                else None
            ),
            "is_available": data.is_available,
            "image_url": (
                data.image_url.strip()
                if data.image_url
                else None
            ),
            "is_vegetarian": data.is_vegetarian,
            "created_at": now,
            "updated_at": now,
        }

        result = await foods.insert_one(food_document)

        saved_food = await foods.find_one({
            "_id": result.inserted_id,
        })

        return {
            "success": True,
            "message": "Food added successfully",
            "food": serialize_food(saved_food),
        }

    except HTTPException:
        raise
    except DuplicateKeyError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Food already exists",
        )
    except PyMongoError:
        logger.exception("Failed to add food")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to add food",
        )


# ---------------------------------------------------------------------------
# GET ALL FOODS
# GET /api/v1/foods/
# ---------------------------------------------------------------------------

@router.get("/")
async def get_all_foods(
    category: Optional[FoodCategory] = None,
    available_only: bool = False,
    vegetarian_only: bool = False,
    search: Optional[str] = Query(default=None, max_length=100),
):
    try:
        query = {}

        if category:
            query["category"] = category.value

        if available_only:
            query["is_available"] = True

        if vegetarian_only:
            query["is_vegetarian"] = True

        if search and search.strip():
            query["name"] = {
                "$regex": search.strip(),
                "$options": "i",
            }

        cursor = foods.find(query).sort("created_at", -1)

        food_list = [
            serialize_food(food)
            async for food in cursor
        ]

        return {
            "success": True,
            "count": len(food_list),
            "foods": food_list,
        }

    except PyMongoError:
        logger.exception("Failed to fetch foods")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch foods",
        )


# ---------------------------------------------------------------------------
# GET FOOD CATEGORIES
# GET /api/v1/foods/categories
# ---------------------------------------------------------------------------

@router.get("/categories")
async def get_food_categories():
    return {
        "success": True,
        "categories": [
            {
                "name": category.value,
                "key": category.name.lower(),
            }
            for category in FoodCategory
        ],
    }


# ---------------------------------------------------------------------------
# GET FOOD BY ID
# GET /api/v1/foods/{food_id}
# ---------------------------------------------------------------------------

@router.get("/{food_id}")
async def get_food_by_id(food_id: str):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID",
        )

    try:
        food = await foods.find_one({
            "_id": ObjectId(food_id),
        })

        if not food:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found",
            )

        return {
            "success": True,
            "food": serialize_food(food),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to fetch food")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch food",
        )


# ---------------------------------------------------------------------------
# UPDATE FOOD
# PUT /api/v1/foods/{food_id}
# ---------------------------------------------------------------------------

@router.put("/{food_id}")
async def edit_food_item(
    food_id: str,
    data: FoodUpdate,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID",
        )

    update_data = data.model_dump(
        exclude_unset=True,
        mode="json",
    )

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one field is required",
        )

    if "name" in update_data and update_data["name"] is not None:
        update_data["name"] = update_data["name"].strip()

    if "description" in update_data and update_data["description"] is not None:
        update_data["description"] = update_data["description"].strip()

    if "image_url" in update_data and update_data["image_url"] is not None:
        update_data["image_url"] = update_data["image_url"].strip()

    try:
        food_object_id = ObjectId(food_id)

        existing = await foods.find_one({
            "_id": food_object_id,
        })

        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found",
            )

        new_name = update_data.get("name", existing.get("name"))
        new_category = update_data.get(
            "category",
            existing.get("category"),
        )

        if new_name and new_category:
            duplicate = await foods.find_one({
                "_id": {"$ne": food_object_id},
                "name": {
                    "$regex": f"^{new_name}$",
                    "$options": "i",
                },
                "category": new_category,
            })

            if duplicate:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Another food with this name already exists in this category",
                )

        update_data["updated_at"] = datetime.now(timezone.utc)

        await foods.update_one(
            {"_id": food_object_id},
            {"$set": update_data},
        )

        updated_food = await foods.find_one({
            "_id": food_object_id,
        })

        return {
            "success": True,
            "message": "Food updated successfully",
            "food": serialize_food(updated_food),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to update food")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update food",
        )


# ---------------------------------------------------------------------------
# UPDATE FOOD AVAILABILITY
# PATCH /api/v1/foods/{food_id}/availability
# ---------------------------------------------------------------------------

@router.patch("/{food_id}/availability")
async def update_food_availability(
    food_id: str,
    data: FoodAvailabilityUpdate,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID",
        )

    try:
        updated_food = await foods.find_one_and_update(
            {"_id": ObjectId(food_id)},
            {
                "$set": {
                    "is_available": data.is_available,
                    "updated_at": datetime.now(timezone.utc),
                }
            },
            return_document=True,
        )

        if not updated_food:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found",
            )

        return {
            "success": True,
            "message": (
                "Food is now available"
                if data.is_available
                else "Food is now unavailable"
            ),
            "food": serialize_food(updated_food),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to update food availability")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update food availability",
        )


# ---------------------------------------------------------------------------
# DELETE FOOD
# DELETE /api/v1/foods/{food_id}
# ---------------------------------------------------------------------------

@router.delete("/{food_id}")
async def delete_food_item(
    food_id: str,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(food_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid food ID",
        )

    try:
        food_object_id = ObjectId(food_id)

        existing = await foods.find_one({
            "_id": food_object_id,
        })

        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Food not found",
            )

        # Preserve historical booking food snapshots.
        # Do not physically delete food records used by existing bookings.
        await foods.update_one(
            {"_id": food_object_id},
            {
                "$set": {
                    "is_available": False,
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        return {
            "success": True,
            "message": "Food disabled successfully",
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to disable food")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to disable food",
        )
