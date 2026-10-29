
import logging
from datetime import date, datetime, timezone
from typing import Literal

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, field_validator
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(prefix="/bookings", tags=["Bookings"])
bearer_scheme = HTTPBearer(auto_error=False)

bookings = customer_db["bookings"]
customers = customer_db["customers"]
notifications = customer_db["notifications"]


# -------------------- REQUEST MODELS --------------------

class BookingCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

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

    @field_validator("event_time", "location")
    @classmethod
    def validate_required_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("This field cannot be empty.")
        return value

    @field_validator("special_requirements")
    @classmethod
    def clean_requirements(cls, value: str) -> str:
        return value.strip()


class BookingStatusUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    status: Literal["confirmed", "rejected", "completed"]


# -------------------- AUTHENTICATION --------------------

def get_token_payload(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise ValueError("Invalid token payload.")

        return payload

    except (jwt.InvalidTokenError, ValueError, TypeError, KeyError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


def get_customer_id(payload: dict = Depends(get_token_payload)) -> str:
    if payload.get("role") != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Customer account required.",
        )

    customer_id = payload.get("sub")

    if not isinstance(customer_id, str) or not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer token.",
        )

    return customer_id


def require_owner(payload: dict = Depends(get_token_payload)) -> dict:
    if payload.get("role") != "owner" or payload.get("sub") != "owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner access required.",
        )

    return payload


# -------------------- BOOKING HELPERS --------------------

def booking_lookup_query(booking_id: str) -> dict:
    """Accept either MongoDB ObjectId or a display ID such as NIV-12ABCDEF."""
    booking_id = booking_id.strip()

    if ObjectId.is_valid(booking_id):
        return {"_id": ObjectId(booking_id)}

    return {"booking_id": booking_id.upper()}


def serialize_booking(booking: dict) -> dict:
    def serialize_datetime(value):
        return value.isoformat() if isinstance(value, datetime) else value

    return {
        "id": str(booking["_id"]),
        "booking_id": booking.get(
            "booking_id", str(booking["_id"])
        ),
        "customer_id": str(booking.get("customer_id", "")),
        "customer_name": booking.get("customer_name", ""),
        "customer_phone": booking.get("customer_phone", ""),
        "customer_email": booking.get("customer_email", ""),
        "function_type": booking.get("function_type"),
        "event_date": serialize_datetime(booking.get("event_date")),
        "event_time": booking.get("event_time"),
        "location": booking.get("location"),
        "persons_count": booking.get("persons_count"),
        "cooking_service": booking.get("cooking_service"),
        "serving_staff_required": booking.get("serving_staff_required"),
        "meal_type": booking.get("meal_type"),
        "food_preference": booking.get("food_preference"),
        "special_requirements": booking.get("special_requirements", ""),
        "status": booking.get("status", "pending"),
        "created_at": serialize_datetime(booking.get("created_at")),
        "updated_at": serialize_datetime(booking.get("updated_at")),
    }


def create_notification(
    recipient_role: str,
    title: str,
    message: str,
    booking: dict,
    customer_id: str | None = None,
) -> None:
    notifications.insert_one({
        "recipient_role": recipient_role,
        "customer_id": customer_id,
        "title": title,
        "message": message,
        "type": "booking",
        "booking_id": booking.get(
            "booking_id", str(booking["_id"])
        ),
        "booking_object_id": str(booking["_id"]),
        "is_read": False,
        "created_at": datetime.now(timezone.utc),
    })


def notify_safely(**kwargs) -> None:
    """Log notification errors without undoing a saved booking."""
    try:
        create_notification(**kwargs)
    except PyMongoError:
        logger.exception(
            "Booking/status saved, but notification creation failed."
        )


def status_filter_for_existing_record(item: dict) -> dict:
    """Build a conditional filter compatible with older bookings."""
    if "status" not in item:
        return {"status": {"$exists": False}}

    return {"status": item["status"]}


# -------------------- CREATE BOOKING --------------------

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
        customer = customers.find_one(
            {"_id": ObjectId(customer_id)},
            {"name": 1, "phone": 1, "email": 1},
        )

        if customer is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Customer account not found.",
            )

        now = datetime.now(timezone.utc)

        # Create both IDs before inserting, avoiding a second update operation.
        mongo_id = ObjectId()
        display_booking_id = f"NIV-{str(mongo_id)[-8:].upper()}"

        booking = {
            "_id": mongo_id,
            "booking_id": display_booking_id,
            "customer_id": customer_id,
            "customer_name": customer.get("name", ""),
            "customer_phone": customer.get("phone", ""),
            "customer_email": customer.get("email", ""),
            "function_type": data.function_type,
            "event_date": data.event_date.isoformat(),
            "event_time": data.event_time,
            "location": data.location,
            "persons_count": data.persons_count,
            "cooking_service": data.cooking_service,
            "serving_staff_required": data.serving_staff_required,
            "meal_type": data.meal_type,
            "food_preference": data.food_preference,
            "special_requirements": data.special_requirements,
            "status": "pending",
            "created_at": now,
            "updated_at": now,
        }

        bookings.insert_one(booking)

        notify_safely(
            recipient_role="owner",
            title="New catering booking",
            message=(
                f"{booking['customer_name'] or 'A customer'} submitted a "
                f"{booking['function_type']} booking for {booking['event_date']}."
            ),
            booking=booking,
        )

        return {
            "success": True,
            "message": "Booking request submitted successfully.",
            "booking": serialize_booking(booking),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to create booking.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to create booking right now.",
        ) from exc


# -------------------- CUSTOMER BOOKINGS --------------------

@router.get("/my-bookings")
def get_my_bookings(customer_id: str = Depends(get_customer_id)):
    try:
        items = list(
            bookings.find({"customer_id": customer_id})
            .sort("created_at", -1)
            .limit(500)
        )

        return {
            "success": True,
            "count": len(items),
            "bookings": [serialize_booking(item) for item in items],
        }

    except PyMongoError as exc:
        logger.exception("Unable to retrieve customer bookings.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve bookings.",
        ) from exc


@router.get("/{booking_id}")
def get_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    try:
        query = booking_lookup_query(booking_id)
        query["customer_id"] = customer_id

        item = bookings.find_one(query)

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        return {"success": True, "booking": serialize_booking(item)}

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to retrieve customer booking.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve booking.",
        ) from exc


@router.patch("/{booking_id}/cancel")
def cancel_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    try:
        query = booking_lookup_query(booking_id)
        query["customer_id"] = customer_id

        item = bookings.find_one(query)

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        current_status = str(item.get("status", "pending")).lower()

        if current_status != "pending":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Only pending bookings can be cancelled directly.",
            )

        conditional_query = {"_id": item["_id"]}
        conditional_query.update(status_filter_for_existing_record(item))

        result = bookings.update_one(
            conditional_query,
            {"$set": {
                "status": "cancelled",
                "updated_at": datetime.now(timezone.utc),
            }},
        )

        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Booking status changed. Refresh and try again.",
            )

        item["status"] = "cancelled"
        item["updated_at"] = datetime.now(timezone.utc)

        notify_safely(
            recipient_role="owner",
            title="Booking cancelled",
            message=(
                f"Booking {item.get('booking_id', str(item['_id']))} "
                "was cancelled by the customer."
            ),
            booking=item,
        )

        return {
            "success": True,
            "message": "Booking cancelled successfully.",
            "booking": serialize_booking(item),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to cancel booking.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to cancel booking.",
        ) from exc


# -------------------- OWNER BOOKINGS --------------------

@router.get("/owner/all")
def get_all_bookings(_: dict = Depends(require_owner)):
    try:
        items = list(
            bookings.find().sort("created_at", -1).limit(1000)
        )

        return {
            "success": True,
            "count": len(items),
            "bookings": [serialize_booking(item) for item in items],
        }

    except PyMongoError as exc:
        logger.exception("Unable to retrieve owner bookings.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve bookings.",
        ) from exc


@router.get("/owner/{booking_id}")
def get_owner_booking(
    booking_id: str,
    _: dict = Depends(require_owner),
):
    try:
        item = bookings.find_one(booking_lookup_query(booking_id))

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        return {"success": True, "booking": serialize_booking(item)}

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to retrieve owner booking.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve booking.",
        ) from exc


@router.patch("/owner/{booking_id}/status")
def update_booking_status(
    booking_id: str,
    data: BookingStatusUpdate,
    _: dict = Depends(require_owner),
):
    try:
        item = bookings.find_one(booking_lookup_query(booking_id))

        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found.",
            )

        current_status = str(item.get("status", "pending")).lower()

        allowed_transitions = {
            "pending": {"confirmed", "rejected"},
            "confirmed": {"completed"},
        }

        if data.status not in allowed_transitions.get(current_status, set()):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    f"Cannot change booking status from '{current_status}' "
                    f"to '{data.status}'."
                ),
            )

        now = datetime.now(timezone.utc)

        conditional_query = {"_id": item["_id"]}
        conditional_query.update(status_filter_for_existing_record(item))

        result = bookings.update_one(
            conditional_query,
            {"$set": {"status": data.status, "updated_at": now}},
        )

        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Booking status changed. Refresh and try again.",
            )

        item["status"] = data.status
        item["updated_at"] = now

        notify_safely(
            recipient_role="customer",
            customer_id=str(item.get("customer_id", "")),
            title="Booking status updated",
            message=(
                f"Your booking {item.get('booking_id', str(item['_id']))} "
                f"is now {data.status}."
            ),
            booking=item,
        )

        return {
            "success": True,
            "message": "Booking status updated successfully.",
            "booking": serialize_booking(item),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to update booking status.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update booking.",
        ) from exc
