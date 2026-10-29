
import logging
from datetime import datetime, timezone

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/reports", tags=["Reports"])
bearer_scheme = HTTPBearer(auto_error=False)

bookings_collection = customer_db["bookings"]
customers_collection = customer_db["customers"]


def get_authenticated_payload(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to view reports.",
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


def get_owner_payload(
    payload: dict = Depends(get_authenticated_payload),
) -> dict:
    # Match this role check to the role claim issued by your owner login.
    if payload.get("role") != "owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner account required.",
        )

    return payload


def serialize_report_booking(booking: dict) -> dict:
    created_at = booking.get("created_at")
    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    event_date = booking.get("event_date")
    if hasattr(event_date, "isoformat"):
        event_date = event_date.isoformat()

    return {
        "id": str(booking["_id"]),
        "booking_id": booking.get("booking_id", str(booking["_id"])),
        "function_type": booking.get(
            "function_type",
            booking.get("event_type", "Not specified"),
        ),
        "event_date": event_date,
        "status": str(booking.get("status", "pending")).lower(),
        "created_at": created_at,
    }


@router.get("/my-bookings")
def get_my_booking_report(
    customer_id: str = Depends(get_customer_id),
):
    """Return booking history and status counts for the logged-in customer."""
    try:
        items = list(
            bookings_collection.find(
                {"customer_id": customer_id},
                {
                    "booking_id": 1,
                    "function_type": 1,
                    "event_type": 1,
                    "event_date": 1,
                    "status": 1,
                    "created_at": 1,
                },
            )
            .sort("created_at", -1)
            .limit(500)
        )

        status_counts: dict[str, int] = {}

        for booking in items:
            booking_status = str(
                booking.get("status", "pending")
            ).lower()
            status_counts[booking_status] = (
                status_counts.get(booking_status, 0) + 1
            )

        return {
            "success": True,
            "report_generated_at": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "total_bookings": len(items),
                "status_counts": status_counts,
            },
            "bookings": [
                serialize_report_booking(booking) for booking in items
            ],
        }

    except PyMongoError as exc:
        logger.exception("Unable to generate customer booking report.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        ) from exc


@router.get("/owner/summary")
def get_owner_report(
    _owner: dict = Depends(get_owner_payload),
):
    """Return booking and customer statistics for the owner dashboard."""
    try:
        total_bookings = bookings_collection.count_documents({})
        total_customers = customers_collection.count_documents({})

        status_counts: dict[str, int] = {}
        for row in bookings_collection.aggregate(
            [
                {
                    "$group": {
                        "_id": {"$toLower": {"$ifNull": ["$status", "pending"]}},
                        "count": {"$sum": 1},
                    }
                }
            ]
        ):
            status_counts[str(row["_id"])] = row["count"]

        recent_items = list(
            bookings_collection.find(
                {},
                {
                    "booking_id": 1,
                    "customer_id": 1,
                    "function_type": 1,
                    "event_type": 1,
                    "event_date": 1,
                    "status": 1,
                    "created_at": 1,
                },
            )
            .sort("created_at", -1)
            .limit(100)
        )

        return {
            "success": True,
            "report_generated_at": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "total_bookings": total_bookings,
                "total_customers": total_customers,
                "pending_bookings": status_counts.get("pending", 0),
                "confirmed_bookings": status_counts.get("confirmed", 0),
                "completed_bookings": status_counts.get("completed", 0),
                "cancelled_bookings": status_counts.get("cancelled", 0),
                "status_counts": status_counts,
            },
            "recent_bookings": [
                serialize_report_booking(booking) for booking in recent_items
            ],
        }

    except PyMongoError as exc:
        logger.exception("Unable to generate owner report.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the owner report right now.",
        ) from exc
