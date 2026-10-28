
from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.errors import PyMongoError
import jwt

from app.core.security import decode_access_token
from app.db.mongo import customer_db


router = APIRouter(prefix="/reports", tags=["Customer Reports"])
bearer_scheme = HTTPBearer(auto_error=False)


def get_customer_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to view your reports.",
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


@router.get("/my-bookings")
def get_my_booking_report(
    customer_id: str = Depends(get_customer_id),
):
    """
    Return a summary of the authenticated customer's bookings.

    Requires a bookings collection in the configured customer database.
    """
    try:
        bookings_collection = customer_db["bookings"]

        bookings = list(
            bookings_collection.find(
                {
                    "$or": [
                        {"customer_id": customer_id},
                        {"customer_id": ObjectId(customer_id)},
                    ]
                },
                {
                    "booking_id": 1,
                    "function_type": 1,
                    "event_type": 1,
                    "event_date": 1,
                    "status": 1,
                    "total_amount": 1,
                    "amount_paid": 1,
                    "created_at": 1,
                },
            ).sort("created_at", -1)
        )

        status_counts = {}
        total_amount = 0.0
        amount_paid = 0.0

        for booking in bookings:
            booking_status = str(booking.get("status", "pending")).lower()
            status_counts[booking_status] = (
                status_counts.get(booking_status, 0) + 1
            )

            total_amount += float(booking.get("total_amount", 0) or 0)
            amount_paid += float(booking.get("amount_paid", 0) or 0)

        report_bookings = []

        for booking in bookings:
            report_bookings.append(
                {
                    "id": str(booking["_id"]),
                    "booking_id": booking.get(
                        "booking_id", str(booking["_id"])
                    ),
                    "function_type": booking.get(
                        "function_type",
                        booking.get("event_type", "Not specified"),
                    ),
                    "event_date": booking.get("event_date"),
                    "status": booking.get("status", "pending"),
                    "total_amount": booking.get("total_amount", 0),
                    "amount_paid": booking.get("amount_paid", 0),
                    "created_at": booking.get("created_at"),
                }
            )

        return {
            "success": True,
            "report_generated_at": datetime.now(timezone.utc),
            "summary": {
                "total_bookings": len(bookings),
                "status_counts": status_counts,
                "total_amount": round(total_amount, 2),
                "amount_paid": round(amount_paid, 2),
                "balance_amount": round(total_amount - amount_paid, 2),
            },
            "bookings": report_bookings,
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        )
