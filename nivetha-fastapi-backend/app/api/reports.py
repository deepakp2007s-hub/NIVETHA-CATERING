import logging
from datetime import UTC, date, datetime
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
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
            raise ValueError("Invalid token payload structure.")

        return payload

    except (jwt.InvalidTokenError, ValueError, TypeError, KeyError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


def get_customer_id(
    payload: dict[str, Any] = Depends(get_authenticated_payload),
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
    payload: dict[str, Any] = Depends(get_authenticated_payload),
) -> dict[str, Any]:
    role = payload.get("role")
    subject = payload.get("sub")

    if role not in {"owner", "admin"} or subject != role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner or Admin access required.",
        )

    return payload


# -------------------- REPORT HELPERS --------------------


def serialize_report_booking(booking: dict[str, Any]) -> dict[str, Any]:
    created_at = booking.get("created_at")
    event_date = booking.get("event_date")

    if isinstance(created_at, (datetime, date)):
        created_at = created_at.isoformat()

    if isinstance(event_date, (datetime, date)):
        event_date = event_date.isoformat()

    return {
        "id": str(booking["_id"]),
        "booking_id": booking.get("booking_id", str(booking["_id"])),
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


def generate_report(
    query: dict[str, Any],
    include_customer: bool = False,
    skip: int = 0,
    limit: int = 50,
) -> dict[str, Any]:
    # Aggregation Pipeline for global status counters
    status_counts_raw = list(
        bookings_collection.aggregate([
            {"$match": query},
            {"$group": {"_id": "$status", "count": {"$sum": 1}}},
        ])
    )

    status_counts: dict[str, int] = {}
    total_bookings = 0
    for item in status_counts_raw:
        st = str(item["_id"]).lower() if item.get("_id") else "pending"
        cnt = item["count"]
        status_counts[st] = cnt
        total_bookings += cnt

    summary = {
        "total_bookings": total_bookings,
        "pending_bookings": status_counts.get("pending", 0),
        "confirmed_bookings": status_counts.get("confirmed", 0),
        "completed_bookings": status_counts.get("completed", 0),
        "cancelled_bookings": status_counts.get("cancelled", 0),
        "rejected_bookings": status_counts.get("rejected", 0),
        "status_counts": status_counts,
    }

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
        bookings_collection.find(query, projection)
        .sort("created_at", -1)
        .skip(skip)
        .limit(limit)
    )

    bookings = [serialize_report_booking(booking) for booking in items]

    if not include_customer:
        for booking in bookings:
            booking.pop("customer_id", None)

    return {
        "success": True,
        "report_generated_at": datetime.now(UTC).isoformat(),
        "summary": summary,
        "count": len(bookings),
        "bookings": bookings,
    }


# -------------------- ENDPOINTS --------------------


@router.get("/my-bookings")
def get_my_booking_report(
    start_date: date | None = Query(None, description="Filter from event date"),
    end_date: date | None = Query(None, description="Filter to event date"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    customer_id: str = Depends(get_customer_id),
):
    try:
        query: dict[str, Any] = {"customer_id": customer_id}

        if start_date or end_date:
            date_filter = {}
            if start_date:
                date_filter["$gte"] = start_date.isoformat()
            if end_date:
                date_filter["$lte"] = end_date.isoformat()
            query["event_date"] = date_filter

        return generate_report(
            query=query,
            include_customer=False,
            skip=skip,
            limit=limit,
        )

    except PyMongoError as exc:
        logger.exception("Unable to generate customer booking report.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        ) from exc


@router.get("/owner/summary")
@router.get("/admin/summary")
def get_staff_booking_report(
    start_date: date | None = Query(None, description="Filter from event date"),
    end_date: date | None = Query(None, description="Filter to event date"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    _: dict = Depends(require_owner_or_admin),
):
    try:
        query: dict[str, Any] = {}

        if start_date or end_date:
            date_filter = {}
            if start_date:
                date_filter["$gte"] = start_date.isoformat()
            if end_date:
                date_filter["$lte"] = end_date.isoformat()
            query["event_date"] = date_filter

        return generate_report(
            query=query,
            include_customer=True,
            skip=skip,
            limit=limit,
        )

    except PyMongoError as exc:
        logger.exception("Unable to generate staff booking report.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate the booking report right now.",
        ) from exc