
from datetime import date, datetime, timezone
from typing import Literal

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


router = APIRouter(prefix="/bookings", tags=["Customer Bookings"])
bearer_scheme = HTTPBearer(auto_error=False)


class BookingCreate(BaseModel):
    function_type: Literal[
        "Wedding",
        "Engagement",
        "Birthday",
        "House Function",
        "Corporate Event",
        "College/School Event",
        "Temple Function",
        "Other",
    ]
    event_date: date
    event_time: str = Field(min_length=1, max_length=50)
    location: str = Field(min_length=3, max_length=300)
    persons_count: int = Field(ge=1, le=100000)
    cooking_service: bool = True
    serving_staff_required: bool = False
    meal_type: Literal["Breakfast", "Lunch", "Dinner", "Multiple"] = "Lunch"
    food_preference: Literal["Veg", "Non-Veg", "Both"] = "Veg"
    special_requirements: str = Field(default="", max_length=2000)


def get_customer_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to manage bookings.",
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

        return customer_id

    except HTTPException:
        raise
    except (jwt.InvalidTokenError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )


def serialize_booking(booking: dict) -> dict:
    return {
        "id": str(booking["_id"]),
        "booking_id": booking.get("booking_id", str(booking["_id"])),
        "customer_id": str(booking.get("customer_id", "")),
        "function_type": booking.get("function_type"),
        "event_date": booking.get("event_date"),
        "event_time": booking.get("event_time"),
        "location": booking.get("location"),
        "persons_count": booking.get("persons_count"),
        "cooking_service": booking.get("cooking_service"),
        "serving_staff_required": booking.get("serving_staff_required"),
        "meal_type": booking.get("meal_type"),
        "food_preference": booking.get("food_preference"),
        "special_requirements": booking.get("special_requirements", ""),
        "status": booking.get("status", "pending"),
        "created_at": booking.get("created_at"),
        "updated_at": booking.get("updated_at"),
    }


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_booking(
    data: BookingCreate,
    customer_id: str = Depends(get_customer_id),
):
    if data.event_date < date.today():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Event date cannot be in the past.",
        )

    try:
        customer = customer_db["customers"].find_one(
            {"_id": ObjectId(customer_id)},
            {"name": 1, "phone": 1, "email": 1},
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Customer account not found.",
            )

        now = datetime.now(timezone.utc)

        booking = {
            "customer_id": customer_id,
            "customer_name": customer.get("name", ""),
            "customer_phone": customer.get("phone", ""),
            "customer_email": customer.get("email", ""),
            "function_type": data.function_type,
            "event_date": data.event_date.isoformat(),
            "event_time": data.event_time.strip(),
            "location": data.location.strip(),
            "persons_count": data.persons_count,
            "cooking_service": data.cooking_service,
            "serving_staff_required": data.serving_staff_required,
            "meal_type": data.meal_type,
            "food_preference": data.food_preference,
            "special_requirements": data.special_requirements.strip(),
            "status": "pending",
            "created_at": now,
            "updated_at": now,
        }

        result = customer_db["bookings"].insert_one(booking)
        booking["_id"] = result.inserted_id
        booking["booking_id"] = f"NIV-{str(result.inserted_id)[-8:].upper()}"

        customer_db["bookings"].update_one(
            {"_id": result.inserted_id},
            {"$set": {"booking_id": booking["booking_id"]}},
        )

        return {
            "success": True,
            "message": "Booking request submitted successfully.",
            "booking": serialize_booking(booking),
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to create booking right now.",
        )


@router.get("/my-bookings")
def get_my_bookings(
    customer_id: str = Depends(get_customer_id),
):
    try:
        bookings = list(
            customer_db["bookings"]
            .find({"customer_id": customer_id})
            .sort("created_at", -1)
        )

        return {
            "success": True,
            "count": len(bookings),
            "bookings": [
                serialize_booking(booking)
                for booking in bookings
            ],
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve bookings right now.",
        )


@router.get("/{booking_id}")
def get_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID.",
        )

    try:
        booking = customer_db["bookings"].find_one(
            {
                "_id": ObjectId(booking_id),
                "customer_id": customer_id,
            }
        )

        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        return {
            "success": True,
            "booking": serialize_booking(booking),
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve booking details right now.",
        )


@router.patch("/{booking_id}/cancel")
def cancel_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID.",
        )

    try:
        bookings = customer_db["bookings"]

        booking = bookings.find_one(
            {
                "_id": ObjectId(booking_id),
                "customer_id": customer_id,
            }
        )

        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        if booking.get("status", "pending").lower() != "pending":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Only pending bookings can be cancelled directly.",
            )

        bookings.update_one(
            {"_id": booking["_id"], "customer_id": customer_id},
            {
                "$set": {
                    "status": "cancelled",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        return {
            "success": True,
            "message": "Booking cancelled successfully.",
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to cancel booking right now.",
        )
