
import logging
from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, ConfigDict, Field
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/reviews",
    tags=["Reviews"],
)

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

reviews = customer_db["reviews"]
customers = customer_db["customers"]


# ---------------------------------------------------------------------------
# SCHEMAS
# ---------------------------------------------------------------------------

class ReviewCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    rating: int = Field(ge=1, le=5)
    comment: str = Field(min_length=3, max_length=2000)


class ReviewUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    rating: Optional[int] = Field(default=None, ge=1, le=5)
    comment: Optional[str] = Field(default=None, min_length=3, max_length=2000)


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

async def get_current_customer(
    token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = decode_access_token(token)

        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

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

        return {
            "customer_id": customer_id,
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

def serialize_review(review: dict) -> dict:
    created_at = review.get("created_at")
    updated_at = review.get("updated_at")

    return {
        "id": str(review["_id"]),
        "customer_id": (
            str(review["customer_id"])
            if isinstance(review.get("customer_id"), ObjectId)
            else review.get("customer_id")
        ),
        "customer_name": review.get("customer_name", "Customer"),
        "rating": review.get("rating", 0),
        "comment": review.get("comment", ""),
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
# GET PUBLIC REVIEWS
# GET /api/v1/reviews/
# ---------------------------------------------------------------------------

@router.get("/")
async def get_public_reviews(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=10, ge=1, le=100),
    rating: Optional[int] = Query(default=None, ge=1, le=5),
):
    try:
        query = {
            "is_visible": {"$ne": False},
        }

        if rating is not None:
            query["rating"] = rating

        total = await reviews.count_documents(query)

        cursor = (
            reviews.find(query)
            .sort("created_at", -1)
            .skip((page - 1) * limit)
            .limit(limit)
        )

        review_list = [
            serialize_review(review)
            async for review in cursor
        ]

        return {
            "success": True,
            "total": total,
            "page": page,
            "limit": limit,
            "total_pages": (total + limit - 1) // limit,
            "reviews": review_list,
        }

    except PyMongoError:
        logger.exception("Failed to fetch public reviews")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch reviews",
        )


# ---------------------------------------------------------------------------
# GET REVIEW SUMMARY
# GET /api/v1/reviews/summary
# ---------------------------------------------------------------------------

@router.get("/summary")
async def get_review_summary():
    try:
        pipeline = [
            {
                "$match": {
                    "is_visible": {"$ne": False},
                    "rating": {"$gte": 1, "$lte": 5},
                }
            },
            {
                "$group": {
                    "_id": None,
                    "average_rating": {"$avg": "$rating"},
                    "total_reviews": {"$sum": 1},
                    "five_star": {
                        "$sum": {
                            "$cond": [{"$eq": ["$rating", 5]}, 1, 0]
                        }
                    },
                    "four_star": {
                        "$sum": {
                            "$cond": [{"$eq": ["$rating", 4]}, 1, 0]
                        }
                    },
                    "three_star": {
                        "$sum": {
                            "$cond": [{"$eq": ["$rating", 3]}, 1, 0]
                        }
                    },
                    "two_star": {
                        "$sum": {
                            "$cond": [{"$eq": ["$rating", 2]}, 1, 0]
                        }
                    },
                    "one_star": {
                        "$sum": {
                            "$cond": [{"$eq": ["$rating", 1]}, 1, 0]
                        }
                    },
                }
            },
        ]

        result = await reviews.aggregate(pipeline).to_list(length=1)

        if not result:
            return {
                "success": True,
                "summary": {
                    "average_rating": 0,
                    "total_reviews": 0,
                    "rating_distribution": {
                        "5": 0,
                        "4": 0,
                        "3": 0,
                        "2": 0,
                        "1": 0,
                    },
                },
            }

        summary = result[0]

        return {
            "success": True,
            "summary": {
                "average_rating": round(
                    summary.get("average_rating", 0),
                    2,
                ),
                "total_reviews": summary.get("total_reviews", 0),
                "rating_distribution": {
                    "5": summary.get("five_star", 0),
                    "4": summary.get("four_star", 0),
                    "3": summary.get("three_star", 0),
                    "2": summary.get("two_star", 0),
                    "1": summary.get("one_star", 0),
                },
            },
        }

    except PyMongoError:
        logger.exception("Failed to calculate review summary")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to calculate review summary",
        )


# ---------------------------------------------------------------------------
# CREATE REVIEW
# POST /api/v1/reviews/
# ---------------------------------------------------------------------------

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_review(
    data: ReviewCreate,
    user: dict = Depends(get_current_customer),
):
    try:
        customer_object_id = ObjectId(user["customer_id"])

        customer = await customers.find_one({
            "_id": customer_object_id,
        })

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer account not found",
            )

        existing_review = await reviews.find_one({
            "customer_id": customer_object_id,
        })

        if existing_review:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You have already submitted a review",
            )

        now = datetime.now(timezone.utc)

        review_document = {
            "customer_id": customer_object_id,
            "customer_name": (
                customer.get("name")
                or customer.get("full_name")
                or "Customer"
            ),
            "rating": data.rating,
            "comment": data.comment.strip(),
            "is_visible": True,
            "created_at": now,
            "updated_at": now,
        }

        result = await reviews.insert_one(review_document)

        saved_review = await reviews.find_one({
            "_id": result.inserted_id,
        })

        return {
            "success": True,
            "message": "Review submitted successfully",
            "review": serialize_review(saved_review),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to create review")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to submit review",
        )


# ---------------------------------------------------------------------------
# GET MY REVIEWS
# GET /api/v1/reviews/my-reviews
# ---------------------------------------------------------------------------

@router.get("/my-reviews")
async def get_my_reviews(
    user: dict = Depends(get_current_customer),
):
    try:
        cursor = (
            reviews.find({
                "customer_id": ObjectId(user["customer_id"]),
            })
            .sort("created_at", -1)
        )

        review_list = [
            serialize_review(review)
            async for review in cursor
        ]

        return {
            "success": True,
            "count": len(review_list),
            "reviews": review_list,
        }

    except PyMongoError:
        logger.exception("Failed to fetch customer reviews")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch your reviews",
        )


# ---------------------------------------------------------------------------
# UPDATE MY REVIEW
# PATCH /api/v1/reviews/{review_id}
# ---------------------------------------------------------------------------

@router.patch("/{review_id}")
async def update_review(
    review_id: str,
    data: ReviewUpdate,
    user: dict = Depends(get_current_customer),
):
    if not ObjectId.is_valid(review_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid review ID",
        )

    update_data = data.model_dump(exclude_unset=True)

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one field is required",
        )

    if "comment" in update_data:
        update_data["comment"] = update_data["comment"].strip()

    try:
        query = {
            "_id": ObjectId(review_id),
            "customer_id": ObjectId(user["customer_id"]),
        }

        update_data["updated_at"] = datetime.now(timezone.utc)

        updated_review = await reviews.find_one_and_update(
            query,
            {"$set": update_data},
            return_document=True,
        )

        if not updated_review:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Review not found",
            )

        return {
            "success": True,
            "message": "Review updated successfully",
            "review": serialize_review(updated_review),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to update review")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update review",
        )


# ---------------------------------------------------------------------------
# DELETE MY REVIEW
# DELETE /api/v1/reviews/{review_id}
# ---------------------------------------------------------------------------

@router.delete("/{review_id}")
async def delete_review(
    review_id: str,
    user: dict = Depends(get_current_customer),
):
    if not ObjectId.is_valid(review_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid review ID",
        )

    try:
        result = await reviews.delete_one({
            "_id": ObjectId(review_id),
            "customer_id": ObjectId(user["customer_id"]),
        })

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Review not found",
            )

        return {
            "success": True,
            "message": "Review deleted successfully",
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to delete review")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to delete review",
        )
