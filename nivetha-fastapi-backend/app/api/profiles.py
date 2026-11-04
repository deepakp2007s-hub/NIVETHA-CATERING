
import logging
import re
from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/profile",
    tags=["Profiles"],
)

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

customers = customer_db["customers"]
bookings = customer_db["bookings"]


# ---------------------------------------------------------------------------
# SCHEMAS
# ---------------------------------------------------------------------------

class ProfileUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    full_name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
    )
    name: Optional[str] = Field(
        default=None,
        min_length=2,
        max_length=100,
    )
    phone: Optional[str] = Field(
        default=None,
        min_length=10,
        max_length=15,
    )
    email: Optional[EmailStr] = None


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

async def get_current_user(
    token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = decode_access_token(token)

        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        role = payload.get("role")
        user_id = payload.get("sub")

        if role not in {"customer", "owner", "admin"}:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid user role",
            )

        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid user account",
            )

        if role == "customer" and not ObjectId.is_valid(user_id):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid customer ID",
            )

        return {
            "user_id": user_id,
            "role": role,
        }

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
        )


# ---------------------------------------------------------------------------
# SERIALIZER
# ---------------------------------------------------------------------------

def serialize_profile(profile: dict) -> dict:
    if not profile:
        return {}

    created_at = profile.get("created_at")
    updated_at = profile.get("updated_at")

    return {
        "id": str(profile["_id"]),
        "full_name": profile.get("full_name") or profile.get("name", ""),
        "name": profile.get("name") or profile.get("full_name", ""),
        "email": profile.get("email", ""),
        "phone": profile.get("phone", ""),
        "role": profile.get("role", "customer"),
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
# GET MY PROFILE
# GET /api/v1/profile/me
# ---------------------------------------------------------------------------

@router.get("/me")
async def get_my_profile(
    user: dict = Depends(get_current_user),
):
    try:
        if user["role"] == "customer":
            collection = customers
            query = {"_id": ObjectId(user["user_id"])}

        elif user["role"] == "owner":
            # Owner credentials are configured through environment settings.
            from app.core.config import settings

            query = {
                "email": settings.OWNER_EMAIL.strip().lower(),
            }
            collection = customers

        else:
            from app.core.config import settings

            query = {
                "email": settings.ADMIN_EMAIL.strip().lower(),
            }
            collection = customers

        profile = await collection.find_one(query)

        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found",
            )

        result = serialize_profile(profile)
        result["role"] = user["role"]

        return {
            "success": True,
            "profile": result,
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to fetch profile")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch profile",
        )


# ---------------------------------------------------------------------------
# UPDATE CUSTOMER PROFILE
# PATCH /api/v1/profile/me
# ---------------------------------------------------------------------------

@router.patch("/me")
async def update_my_profile(
    data: ProfileUpdate,
    user: dict = Depends(get_current_user),
):
    if user["role"] != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only customers can update their profile here",
        )

    update_data = data.model_dump(exclude_unset=True)

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one field is required",
        )

    if "name" in update_data and "full_name" in update_data:
        if update_data["name"].strip() != update_data["full_name"].strip():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="name and full_name must match when both are provided",
            )

    name = update_data.get("full_name") or update_data.get("name")

    if name is not None:
        name = name.strip()

        if len(name) < 2:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Name must contain at least 2 characters",
            )

        update_data["name"] = name
        update_data["full_name"] = name

    if "phone" in update_data:
        phone = update_data["phone"].strip()

        if not re.fullmatch(r"[0-9]{10,15}", phone):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Enter a valid phone number containing 10 to 15 digits",
            )

        update_data["phone"] = phone

    if "email" in update_data:
        update_data["email"] = str(update_data["email"]).strip().lower()

    try:
        customer_object_id = ObjectId(user["user_id"])

        existing = await customers.find_one({
            "_id": customer_object_id,
        })

        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer profile not found",
            )

        if "email" in update_data:
            duplicate_email = await customers.find_one({
                "email": update_data["email"],
                "_id": {"$ne": customer_object_id},
            })

            if duplicate_email:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Email already registered",
                )

        if "phone" in update_data:
            duplicate_phone = await customers.find_one({
                "phone": update_data["phone"],
                "_id": {"$ne": customer_object_id},
            })

            if duplicate_phone:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Phone number already registered",
                )

        update_data["updated_at"] = datetime.now(timezone.utc)

        await customers.update_one(
            {"_id": customer_object_id},
            {"$set": update_data},
        )

        updated_profile = await customers.find_one({
            "_id": customer_object_id,
        })

        return {
            "success": True,
            "message": "Profile updated successfully",
            "profile": serialize_profile(updated_profile),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to update customer profile")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update profile",
        )


# ---------------------------------------------------------------------------
# CUSTOMER BOOKING HISTORY
# GET /api/v1/profile/my-bookings
# ---------------------------------------------------------------------------

@router.get("/my-bookings")
async def get_my_booking_history(
    user: dict = Depends(get_current_user),
):
    if user["role"] != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Customer access required",
        )

    try:
        customer_object_id = ObjectId(user["user_id"])

        cursor = (
            bookings.find({
                "customer_id": customer_object_id,
            })
            .sort("created_at", -1)
        )

        booking_list = []

        async for booking in cursor:
            created_at = booking.get("created_at")
            updated_at = booking.get("updated_at")

            booking_list.append({
                "id": str(booking["_id"]),
                "function_type": booking.get("function_type"),
                "event_date": booking.get("event_date"),
                "event_time": booking.get("event_time"),
                "location": booking.get("location"),
                "persons_count": booking.get("persons_count"),
                "meal_type": booking.get("meal_type"),
                "food_preference": booking.get("food_preference"),
                "selected_foods": booking.get("selected_foods", []),
                "status": booking.get("status"),
                "owner_note": booking.get("owner_note"),
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
            })

        return {
            "success": True,
            "count": len(booking_list),
            "bookings": booking_list,
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to fetch customer booking history")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch booking history",
        )
