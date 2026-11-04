
import logging
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/reports",
    tags=["Reports"],
)

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/owner/login"
)

bookings = customer_db["bookings"]
customers = customer_db["customers"]
foods = customer_db["foods"]


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

async def require_owner_or_admin(
    token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = decode_access_token(token)

        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        if payload.get("role") not in {"owner", "admin"}:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Owner or admin access required",
            )

        return payload

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
        )


# ---------------------------------------------------------------------------
# DASHBOARD SUMMARY
# GET /api/v1/reports/summary
# ---------------------------------------------------------------------------

@router.get("/summary")
async def get_dashboard_summary(
    user: dict = Depends(require_owner_or_admin),
):
    try:
        total_bookings = await bookings.count_documents({})
        pending_bookings = await bookings.count_documents({
            "status": "pending",
        })
        confirmed_bookings = await bookings.count_documents({
            "status": "confirmed",
        })
        rejected_bookings = await bookings.count_documents({
            "status": "rejected",
        })
        completed_bookings = await bookings.count_documents({
            "status": "completed",
        })
        cancelled_bookings = await bookings.count_documents({
            "status": "cancelled",
        })

        total_customers = await customers.count_documents({})
        total_foods = await foods.count_documents({})
        available_foods = await foods.count_documents({
            "is_available": True,
        })
        unavailable_foods = await foods.count_documents({
            "is_available": False,
        })

        return {
            "success": True,
            "summary": {
                "total_bookings": total_bookings,
                "pending_bookings": pending_bookings,
                "confirmed_bookings": confirmed_bookings,
                "rejected_bookings": rejected_bookings,
                "completed_bookings": completed_bookings,
                "cancelled_bookings": cancelled_bookings,
                "total_customers": total_customers,
                "total_foods": total_foods,
                "available_foods": available_foods,
                "unavailable_foods": unavailable_foods,
            },
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    except PyMongoError:
        logger.exception("Failed to generate dashboard summary")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate dashboard summary",
        )


# ---------------------------------------------------------------------------
# BOOKING STATUS REPORT
# GET /api/v1/reports/bookings
# ---------------------------------------------------------------------------

@router.get("/bookings")
async def get_booking_report(
    status_filter: Optional[str] = Query(default=None, alias="status"),
    user: dict = Depends(require_owner_or_admin),
):
    allowed_statuses = {
        "pending",
        "confirmed",
        "rejected",
        "completed",
        "cancelled",
    }

    if status_filter and status_filter not in allowed_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid booking status",
        )

    try:
        match_stage = {}

        if status_filter:
            match_stage["status"] = status_filter

        pipeline = []

        if match_stage:
            pipeline.append({"$match": match_stage})

        pipeline.extend([
            {
                "$group": {
                    "_id": "$status",
                    "count": {"$sum": 1},
                }
            },
            {
                "$sort": {"count": -1},
            },
        ])

        result = await bookings.aggregate(pipeline).to_list(length=None)

        status_counts = {
            "pending": 0,
            "confirmed": 0,
            "rejected": 0,
            "completed": 0,
            "cancelled": 0,
        }

        for item in result:
            if item["_id"] in status_counts:
                status_counts[item["_id"]] = item["count"]

        return {
            "success": True,
            "booking_status_report": status_counts,
            "total": sum(status_counts.values()),
        }

    except PyMongoError:
        logger.exception("Failed to generate booking report")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate booking report",
        )


# ---------------------------------------------------------------------------
# POPULAR FOODS REPORT
# GET /api/v1/reports/popular-foods
# ---------------------------------------------------------------------------

@router.get("/popular-foods")
async def get_popular_foods(
    limit: int = Query(default=10, ge=1, le=100),
    user: dict = Depends(require_owner_or_admin),
):
    try:
        pipeline = [
            {
                "$match": {
                    "status": {
                        "$in": ["confirmed", "completed"],
                    },
                    "selected_foods": {
                        "$exists": True,
                        "$ne": [],
                    },
                }
            },
            {
                "$unwind": "$selected_foods",
            },
            {
                "$group": {
                    "_id": {
                        "$ifNull": [
                            "$selected_foods.food_id",
                            "$selected_foods.food_name",
                        ]
                    },
                    "food_name": {
                        "$first": "$selected_foods.food_name",
                    },
                    "category": {
                        "$first": "$selected_foods.category",
                    },
                    "selection_count": {
                        "$sum": 1,
                    },
                }
            },
            {
                "$sort": {
                    "selection_count": -1,
                }
            },
            {
                "$limit": limit,
            },
        ]

        result = await bookings.aggregate(pipeline).to_list(
            length=limit
        )

        popular_foods = []

        for index, item in enumerate(result, start=1):
            popular_foods.append({
                "rank": index,
                "food_id": (
                    str(item["_id"])
                    if item.get("_id") is not None
                    else None
                ),
                "food_name": item.get("food_name") or str(item["_id"]),
                "category": item.get("category"),
                "selection_count": item.get("selection_count", 0),
            })

        return {
            "success": True,
            "count": len(popular_foods),
            "popular_foods": popular_foods,
        }

    except PyMongoError:
        logger.exception("Failed to generate popular foods report")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate popular foods report",
        )


# ---------------------------------------------------------------------------
# MONTHLY BOOKING REPORT
# GET /api/v1/reports/monthly-bookings
# ---------------------------------------------------------------------------

@router.get("/monthly-bookings")
async def get_monthly_booking_report(
    year: int = Query(
        default_factory=lambda: datetime.now(timezone.utc).year,
        ge=2000,
        le=2100,
    ),
    user: dict = Depends(require_owner_or_admin),
):
    try:
        pipeline = [
            {
                "$addFields": {
                    "parsed_event_date": {
                        "$dateFromString": {
                            "dateString": "$event_date",
                            "onError": None,
                            "onNull": None,
                        }
                    }
                }
            },
            {
                "$match": {
                    "parsed_event_date": {
                        "$ne": None,
                        "$gte": datetime(year, 1, 1, tzinfo=timezone.utc),
                        "$lt": datetime(year + 1, 1, 1, tzinfo=timezone.utc),
                    }
                }
            },
            {
                "$group": {
                    "_id": {
                        "month": {
                            "$month": "$parsed_event_date",
                        },
                        "status": "$status",
                    },
                    "count": {
                        "$sum": 1,
                    },
                }
            },
            {
                "$sort": {
                    "_id.month": 1,
                }
            },
        ]

        result = await bookings.aggregate(pipeline).to_list(
            length=None
        )

        monthly_data = []

        for month in range(1, 13):
            status_counts = {
                "pending": 0,
                "confirmed": 0,
                "rejected": 0,
                "completed": 0,
                "cancelled": 0,
            }

            for item in result:
                if item["_id"]["month"] == month:
                    booking_status = item["_id"]["status"]

                    if booking_status in status_counts:
                        status_counts[booking_status] = item["count"]

            monthly_data.append({
                "month": month,
                "month_name": datetime(year, month, 1).strftime("%B"),
                "total": sum(status_counts.values()),
                "statuses": status_counts,
            })

        return {
            "success": True,
            "year": year,
            "monthly_bookings": monthly_data,
        }

    except PyMongoError:
        logger.exception("Failed to generate monthly booking report")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate monthly booking report",
        )


# ---------------------------------------------------------------------------
# FUNCTION TYPE REPORT
# GET /api/v1/reports/function-types
# ---------------------------------------------------------------------------

@router.get("/function-types")
async def get_function_type_report(
    user: dict = Depends(require_owner_or_admin),
):
    try:
        pipeline = [
            {
                "$group": {
                    "_id": "$function_type",
                    "booking_count": {
                        "$sum": 1,
                    },
                }
            },
            {
                "$sort": {
                    "booking_count": -1,
                }
            },
        ]

        result = await bookings.aggregate(pipeline).to_list(
            length=None
        )

        function_types = [
            {
                "function_type": item["_id"],
                "booking_count": item["booking_count"],
            }
            for item in result
        ]

        return {
            "success": True,
            "count": len(function_types),
            "function_types": function_types,
        }

    except PyMongoError:
        logger.exception("Failed to generate function type report")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate function type report",
        )


# ---------------------------------------------------------------------------
# MEAL TYPE REPORT
# GET /api/v1/reports/meal-types
# ---------------------------------------------------------------------------

@router.get("/meal-types")
async def get_meal_type_report(
    user: dict = Depends(require_owner_or_admin),
):
    try:
        pipeline = [
            {
                "$group": {
                    "_id": "$meal_type",
                    "booking_count": {
                        "$sum": 1,
                    },
                }
            },
            {
                "$sort": {
                    "booking_count": -1,
                }
            },
        ]

        result = await bookings.aggregate(pipeline).to_list(
            length=None
        )

        meal_types = [
            {
                "meal_type": item["_id"],
                "booking_count": item["booking_count"],
            }
            for item in result
        ]

        return {
            "success": True,
            "count": len(meal_types),
            "meal_types": meal_types,
        }

    except PyMongoError:
        logger.exception("Failed to generate meal type report")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to generate meal type report",
        )
