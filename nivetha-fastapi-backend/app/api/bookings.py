
import logging
from datetime import date, datetime, timezone
from typing import Literal, Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, Field, ConfigDict
from pymongo import ReturnDocument
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(prefix="/bookings", tags=["Bookings"])

bookings = customer_db["bookings"]
customers = customer_db["customers"]
foods = customer_db["foods"]
notifications = customer_db["notifications"]

customer_oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

staff_oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/owner-login"
)


# ---------------------------------------------------------------------------
# SCHEMAS
# ---------------------------------------------------------------------------

FunctionType = Literal[
    "Wedding",
    "Engagement",
    "Birthday",
    "House Function",
    "Corporate Event",
    "College/School Event",
    "Temple Function",
    "Other",
]

MealType = Literal["Breakfast", "Lunch", "Dinner", "Multiple"]
FoodPreference = Literal["Veg", "Non-Veg", "Both"]

BookingStatus = Literal[
    "pending",
    "confirmed",
    "rejected",
    "completed",
    "cancelled",
]


class SelectedFoodItem(BaseModel):
    model_config = ConfigDict(extra="ignore")

    food_id: str
    food_name: Optional[str] = None
    category: Optional[
        Literal["Breakfast", "Lunch", "Dinner", "Sweets"]
    ] = None


class BookingCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    function_type: FunctionType
    event_date: date
    event_time: str = Field(min_length=1, max_length=50)
    location: str = Field(min_length=3, max_length=500)
    persons_count: int = Field(gt=0, le=100000)

    catering_service_required: bool = True
    cooking_service: bool = True
    serving_staff_required: bool = False

    meal_type: MealType
    food_preference: FoodPreference
    selected_foods: list[SelectedFoodItem] = Field(default_factory=list)

    special_requirements: Optional[str] = Field(
        default=None,
        max_length=2000,
    )


class BookingStatusUpdate(BaseModel):
    status: Literal["confirmed", "rejected", "completed"]
    owner_note: Optional[str] = Field(default=None, max_length=1000)


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

def get_token_payload(token: str) -> dict:
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


async def get_customer_id(
    token: str = Depends(customer_oauth2_scheme),
) -> str:
    payload = get_token_payload(token)

    if payload.get("role") != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Customer access required",
        )

    customer_id = payload.get("sub")

    if not customer_id or not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer account",
        )

    return customer_id


async def require_owner_or_admin(
    token: str = Depends(staff_oauth2_scheme),
) -> dict:
    payload = get_token_payload(token)

    if payload.get("role") not in {"owner", "admin"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner or admin access required",
        )

    return payload


# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

def serialize_booking(booking: dict) -> dict:
    if not booking:
        return {}

    result = dict(booking)
    result["id"] = str(result.pop("_id", ""))

    if isinstance(result.get("customer_id"), ObjectId):
        result["customer_id"] = str(result["customer_id"])

    for key in ("created_at", "updated_at", "event_date"):
        value = result.get(key)

        if isinstance(value, (datetime, date)):
            result[key] = value.isoformat()

    return result


def serialize_food(food: dict) -> dict:
    return {
        "food_id": str(food["_id"]),
        "food_name": food.get("name", ""),
        "category": food.get("category"),
    }


async def validate_selected_foods(
    items: list[SelectedFoodItem],
) -> list[dict]:
    validated_foods = []
    seen_ids = set()

    for item in items:
        if not ObjectId.is_valid(item.food_id):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid food ID: {item.food_id}",
            )

        if item.food_id in seen_ids:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Duplicate food selection is not allowed",
            )

        seen_ids.add(item.food_id)
        food_object_id = ObjectId(item.food_id)

        food = await foods.find_one({"_id": food_object_id})

        if not food:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Food item not found: {item.food_id}",
            )

        if food.get("is_available") is False:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{food.get('name', 'Selected food')} is currently unavailable",
            )

        validated_foods.append(serialize_food(food))

    return validated_foods


async def create_notification(
    recipient_role: str,
    title: str,
    message: str,
    customer_id: Optional[str] = None,
    booking_id: Optional[str] = None,
) -> None:
    notification = {
        "recipient_role": recipient_role,
        "title": title,
        "message": message,
        "is_read": False,
        "created_at": datetime.now(timezone.utc),
    }

    if customer_id:
        notification["customer_id"] = customer_id

    if booking_id:
        notification["booking_id"] = booking_id

    await notifications.insert_one(notification)


async def notify_safely(**kwargs) -> None:
    try:
        await create_notification(**kwargs)
    except Exception:
        logger.exception("Failed to create booking notification")


def booking_query_for_customer(
    booking_id: str,
    customer_id: str,
) -> dict:
    return {
        "_id": ObjectId(booking_id),
        "customer_id": ObjectId(customer_id),
    }


async def build_booking_data(data: BookingCreate) -> dict:
    if data.event_date < date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Event date cannot be in the past",
        )

    selected_foods = await validate_selected_foods(
        data.selected_foods
    )

    return {
        "function_type": data.function_type,
        "event_date": data.event_date.isoformat(),
        "event_time": data.event_time.strip(),
        "location": data.location.strip(),
        "persons_count": data.persons_count,
        "catering_service_required": data.catering_service_required,
        "cooking_service": data.cooking_service,
        "serving_staff_required": data.serving_staff_required,
        "meal_type": data.meal_type,
        "food_preference": data.food_preference,
        "selected_foods": selected_foods,
        "special_requirements": (
            data.special_requirements.strip()
            if data.special_requirements
            else None
        ),
    }


# ---------------------------------------------------------------------------
# CUSTOMER: BOOKING PREVIEW
# ---------------------------------------------------------------------------

@router.post("/preview")
async def preview_booking(
    data: BookingCreate,
    customer_id: str = Depends(get_customer_id),
):
    try:
        booking_data = await build_booking_data(data)

        return {
            "success": True,
            "message": "Booking preview generated successfully",
            "booking": booking_data,
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while generating booking preview")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate booking preview",
        )


# ---------------------------------------------------------------------------
# CUSTOMER: CREATE BOOKING
# ---------------------------------------------------------------------------

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_booking(
    data: BookingCreate,
    customer_id: str = Depends(get_customer_id),
):
    try:
        customer_object_id = ObjectId(customer_id)

        customer = await customers.find_one(
            {"_id": customer_object_id}
        )

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer account not found",
            )

        pending_count = await bookings.count_documents({
            "customer_id": customer_object_id,
            "status": "pending",
        })

        if pending_count >= 5:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You can have a maximum of 5 pending bookings",
            )

        booking_data = await build_booking_data(data)
        now = datetime.now(timezone.utc)

        booking_data.update({
            "customer_id": customer_object_id,
            "customer_name": (
                customer.get("name")
                or customer.get("full_name", "")
            ),
            "customer_email": customer.get("email", ""),
            "customer_phone": customer.get("phone", ""),
            "status": "pending",
            "owner_note": None,
            "created_at": now,
            "updated_at": now,
        })

        result = await bookings.insert_one(booking_data)
        booking_id = str(result.inserted_id)

        await notify_safely(
            recipient_role="owner",
            title="New Catering Booking",
            message=(
                f"{booking_data['customer_name']} submitted a new "
                f"{booking_data['function_type']} booking."
            ),
            customer_id=customer_id,
            booking_id=booking_id,
        )

        saved_booking = await bookings.find_one({
            "_id": result.inserted_id
        })

        return {
            "success": True,
            "message": "Booking submitted successfully",
            "booking": serialize_booking(saved_booking),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while creating booking")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to create booking",
        )

    except Exception:
        logger.exception("Unexpected error while creating booking")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Something went wrong while creating booking",
        )


# ---------------------------------------------------------------------------
# CUSTOMER: MY BOOKINGS
# ---------------------------------------------------------------------------

@router.get("/my-bookings")
async def get_my_bookings(
    customer_id: str = Depends(get_customer_id),
):
    try:
        cursor = bookings.find({
            "customer_id": ObjectId(customer_id),
        }).sort("created_at", -1)

        results = [
            serialize_booking(booking)
            async for booking in cursor
        ]

        return {
            "success": True,
            "count": len(results),
            "bookings": results,
        }

    except PyMongoError:
        logger.exception("Database error while fetching customer bookings")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch bookings",
        )


# ---------------------------------------------------------------------------
# CUSTOMER: EDIT PENDING BOOKING
# ---------------------------------------------------------------------------

@router.put("/{booking_id}")
async def update_my_booking(
    booking_id: str,
    data: BookingCreate,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID",
        )

    try:
        booking_data = await build_booking_data(data)
        now = datetime.now(timezone.utc)

        updated = await bookings.find_one_and_update(
            {
                **booking_query_for_customer(
                    booking_id,
                    customer_id,
                ),
                "status": "pending",
            },
            {
                "$set": {
                    **booking_data,
                    "updated_at": now,
                }
            },
            return_document=ReturnDocument.AFTER,
        )

        if not updated:
            existing = await bookings.find_one(
                booking_query_for_customer(
                    booking_id,
                    customer_id,
                )
            )

            if not existing:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Booking not found",
                )

            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only pending bookings can be edited",
            )

        await notify_safely(
            recipient_role="owner",
            title="Booking Updated",
            message=(
                f"{updated.get('customer_name', 'Customer')} "
                "updated a booking."
            ),
            customer_id=customer_id,
            booking_id=booking_id,
        )

        return {
            "success": True,
            "message": "Booking updated successfully",
            "booking": serialize_booking(updated),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while updating booking")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update booking",
        )


# ---------------------------------------------------------------------------
# CUSTOMER: CANCEL PENDING BOOKING
# ---------------------------------------------------------------------------

@router.patch("/{booking_id}/cancel")
async def cancel_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID",
        )

    try:
        updated = await bookings.find_one_and_update(
            {
                **booking_query_for_customer(
                    booking_id,
                    customer_id,
                ),
                "status": "pending",
            },
            {
                "$set": {
                    "status": "cancelled",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
            return_document=ReturnDocument.AFTER,
        )

        if not updated:
            existing = await bookings.find_one(
                booking_query_for_customer(
                    booking_id,
                    customer_id,
                )
            )

            if not existing:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Booking not found",
                )

            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only pending bookings can be cancelled",
            )

        await notify_safely(
            recipient_role="owner",
            title="Booking Cancelled",
            message=(
                f"{updated.get('customer_name', 'Customer')} "
                "cancelled a booking."
            ),
            customer_id=customer_id,
            booking_id=booking_id,
        )

        return {
            "success": True,
            "message": "Booking cancelled successfully",
            "booking": serialize_booking(updated),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while cancelling booking")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to cancel booking",
        )


# ---------------------------------------------------------------------------
# OWNER / ADMIN: GET BOOKINGS AT COLLECTION ROOT
# ---------------------------------------------------------------------------

@router.get("/", summary="Get all bookings for owner or admin")
async def get_bookings_for_owner(
    status_filter: Optional[BookingStatus] = None,
    user: dict = Depends(require_owner_or_admin),
):
    try:
        query = {}

        if status_filter:
            query["status"] = status_filter

        cursor = bookings.find(query).sort("created_at", -1)

        results = [
            serialize_booking(booking)
            async for booking in cursor
        ]

        return {
            "success": True,
            "count": len(results),
            "bookings": results,
        }

    except PyMongoError:
        logger.exception("Database error while fetching owner bookings")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch bookings",
        )

    except Exception:
        logger.exception("Unexpected error while fetching owner bookings")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Something went wrong while fetching bookings",
        )


# ---------------------------------------------------------------------------
# OWNER: GET ALL BOOKINGS
# ---------------------------------------------------------------------------

@router.get("/owner/all")
async def get_all_bookings(
    status_filter: Optional[BookingStatus] = None,
    user: dict = Depends(require_owner_or_admin),
):
    try:
        query = {}

        if status_filter:
            query["status"] = status_filter

        cursor = bookings.find(query).sort("created_at", -1)

        results = [
            serialize_booking(booking)
            async for booking in cursor
        ]

        return {
            "success": True,
            "count": len(results),
            "bookings": results,
        }

    except PyMongoError:
        logger.exception("Database error while fetching all bookings")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch bookings",
        )


# ---------------------------------------------------------------------------
# OWNER: GET SINGLE BOOKING
# ---------------------------------------------------------------------------

@router.get("/owner/{booking_id}")
async def get_owner_booking(
    booking_id: str,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID",
        )

    try:
        booking = await bookings.find_one({
            "_id": ObjectId(booking_id)
        })

        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found",
            )

        return {
            "success": True,
            "booking": serialize_booking(booking),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while fetching booking")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch booking",
        )


# ---------------------------------------------------------------------------
# OWNER: CONFIRM / REJECT / COMPLETE
# ---------------------------------------------------------------------------

@router.patch("/owner/{booking_id}/status")
async def update_booking_status(
    booking_id: str,
    data: BookingStatusUpdate,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID",
        )

    try:
        booking_object_id = ObjectId(booking_id)

        existing = await bookings.find_one({
            "_id": booking_object_id
        })

        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found",
            )

        current_status = existing.get("status", "pending")

        allowed_transitions = {
            "pending": {"confirmed", "rejected"},
            "confirmed": {"completed"},
        }

        if data.status not in allowed_transitions.get(
            current_status,
            set(),
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Cannot change booking status from "
                    f"{current_status} to {data.status}"
                ),
            )

        now = datetime.now(timezone.utc)

        updated = await bookings.find_one_and_update(
            {
                "_id": booking_object_id,
                "status": current_status,
            },
            {
                "$set": {
                    "status": data.status,
                    "owner_note": data.owner_note,
                    "updated_at": now,
                }
            },
            return_document=ReturnDocument.AFTER,
        )

        if not updated:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "Booking was updated by another request. "
                    "Refresh and try again."
                ),
            )

        customer_id = str(updated.get("customer_id", ""))

        await notify_safely(
            recipient_role="customer",
            title=f"Booking {data.status.title()}",
            message=(
                data.owner_note
                or f"Your catering booking has been {data.status}."
            ),
            customer_id=customer_id,
            booking_id=booking_id,
        )

        return {
            "success": True,
            "message": f"Booking {data.status} successfully",
            "booking": serialize_booking(updated),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("Database error while updating booking status")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update booking status",
        )


# ---------------------------------------------------------------------------
# CUSTOMER: GET SINGLE BOOKING
# ---------------------------------------------------------------------------

@router.get("/{booking_id}")
async def get_my_booking(
    booking_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(booking_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking ID",
        )

    try:
        booking = await bookings.find_one(
            booking_query_for_customer(
                booking_id,
                customer_id,
            )
        )

        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found",
            )

        return {
            "success": True,
            "booking": serialize_booking(booking),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception(
            "Database error while fetching customer booking"
        )
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch booking",
        )
