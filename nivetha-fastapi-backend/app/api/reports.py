import logging
from datetime import UTC, datetime
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/reports",
    tags=["Booking Reports"],
)

bearer_scheme = HTTPBearer(auto_error=False)

bookings_collection = customer_db["bookings"]


# -------------------- AUTHENTICATION --------------------


def get_authenticated_payload(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict[str, Any]:
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


def get_customer_id(
    payload: dict = Depends(get_authenticated_payload),
) -> str:
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
        )

    return customer_id


def require_owner_or_admin(
    payload: dict = Depends(get_authenticated_payload),
) -> dict:
    role = payload.get("role")
    subject = payload.get("sub")

    if role not in {"owner", "admin"} or subject != role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner or Admin access required.",
        )

    return payload


# -------------------- REPORT HELPERS --------------------


def serialize_report_booking(booking: dict) -> dict:
    created_at = booking.get("created_at")
    event_date = booking.get("event_date")

    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    if isinstance(event_date, (datetime,)) or hasattr(event_date, "isoformat"):
        event_date = event_date.isoformat()

    return {
        "id": str(booking["_id"]),
        "booking_id": booking.get(
            "booking_id",
            str(booking["_id"]),
        ),
        "customer_id": booking.get("customer_id"),
        "function_type": booking.get(
            "function_type",
            booking.get("event_type", "Not specified"),
        ),
        "event_date": event_date,
        "event_time": booking.get("event_time"),
        "status": str(booking.get("status", "pending")).lower(),
        "created_at": created_at,
    }


def build_status_summary(items: list[dict]) -> dict:
    status_counts: dict[str, int] = {}

    for booking in items:
        booking_status = str(booking.get("status", "pending")).lower()

        status_counts[booking_status] = status_counts.get(booking_status, 0) + 1

    return {
        "total_bookings": len(items),
        "pending_bookings": status_counts.get("pending", 0),
        "confirmed_bookings": status_counts.get("confirmed", 0),
        "completed_bookings": status_counts.get("completed", 0),
        "cancelled_bookings": status_counts.get("cancelled", 0),
        "rejected_bookings": status_counts.get("rejected", 0),
        "status_counts": status_counts,
    }


def generate_report(query: dict, include_customer: bool = False) -> dict:
    projection = {
        "booking_id": 1,
        "customer_id": 1,
        "function_type": 1,
        "event_type": 1,
        "event_date": 1,
        "event_time": 1,
        "status": 1,
        "created_at": 1,
    }

    items = list(
        bookings_collection.find(query, projection).sort("created_at", -1).limit(500)
    )

    summary = build_status_summary(items)

    bookings = [serialize_report_booking(booking) for booking in items]

    if not include_customer:
        for booking in bookings:
            booking.pop("customer_id", None)

    return {
        "success": True,
        "report_generated_at": datetime.now(UTC).isoformat(),
        "summary": summary,
        "bookings": bookings,
    }


# -------------------- CUSTOMER REPORT --------------------


@router.get("/my-bookings")
def get_my_booking_report(
    customer_id: str = Depends(get_customer_id),
):
    try:
        return generate_report(
            {"customer_id": customer_id},
            include_customer=False,
        )

    except PyMongoError as exc:
        logger.exception("Unable to generate customer booking report.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        ) from exc


# -------------------- OWNER / ADMIN REPORT --------------------


@router.get("/owner/summary")
@router.get("/admin/summary")
def get_staff_booking_report(
    _: dict = Depends(require_owner_or_admin),
):
    try:
        return generate_report(
            {},
            include_customer=True,
        )

    except PyMongoError as exc:
        logger.exception("Unable to generate staff booking report.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        ) from exc
