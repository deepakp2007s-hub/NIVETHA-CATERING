import logging
from datetime import UTC, datetime
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, field_validator
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/reviews",
    tags=["Customer Reviews"],
)

bearer_scheme = HTTPBearer(auto_error=False)

reviews_collection = customer_db["reviews"]
customers_collection = customer_db["customers"]


# -------------------- REQUEST MODEL --------------------


class ReviewRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    rating: int = Field(ge=1, le=5, strict=True)
    comment: str = Field(min_length=3, max_length=1000)

    @field_validator("comment")
    @classmethod
    def validate_comment(cls, value: str) -> str:
        value = value.strip()

        if len(value) < 3:
            raise ValueError("Comment must contain at least 3 characters.")

        return value


# -------------------- AUTHENTICATION --------------------


def get_customer_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to access reviews.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise ValueError("Invalid token payload.")

        if payload.get("role") != "customer":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customer account required.",
            )

        customer_id = payload.get("sub")

        if not isinstance(customer_id, str) or not ObjectId.is_valid(customer_id):
            raise ValueError("Invalid customer ID.")

        return customer_id

    except HTTPException:
        raise

    except (
        jwt.InvalidTokenError,
        ValueError,
        TypeError,
        KeyError,
    ) as exc:
        logger.warning("Review request rejected due to invalid authentication.")

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


# -------------------- SERIALIZATION --------------------


def serialize_review(review: dict[str, Any]) -> dict[str, Any]:
    created_at = review.get("created_at")

    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    return {
        "id": str(review["_id"]),
        "customer_id": str(review.get("customer_id", "")),
        "customer_name": review.get("customer_name", "Customer"),
        "rating": review.get("rating", 0),
        "comment": review.get("comment", ""),
        "created_at": created_at,
    }


# -------------------- CREATE REVIEW --------------------


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
)
def create_review(
    data: ReviewRequest,
    customer_id: str = Depends(get_customer_id),
):
    try:
        customer = customers_collection.find_one(
            {"_id": ObjectId(customer_id)},
            {"name": 1},
        )

        if customer is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Customer account not found.",
            )

        review = {
            "customer_id": customer_id,
            "customer_name": customer.get("name") or "Customer",
            "rating": data.rating,
            "comment": data.comment,
            "created_at": datetime.now(UTC),
        }

        result = reviews_collection.insert_one(review)
        review["_id"] = result.inserted_id

        logger.info("Customer review created successfully.")

        return {
            "success": True,
            "message": "Review submitted successfully.",
            "review": serialize_review(review),
        }

    except HTTPException:
        raise

    except PyMongoError as exc:
        logger.exception("MongoDB error while creating review.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to save review right now. Please try again later.",
        ) from exc


# -------------------- CUSTOMER REVIEW HISTORY --------------------


@router.get("/my-reviews")
def get_my_reviews(
    customer_id: str = Depends(get_customer_id),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
):
    try:
        query = {"customer_id": customer_id}

        total = reviews_collection.count_documents(query)

        items = list(
            reviews_collection.find(query)
            .sort("created_at", -1)
            .skip((page - 1) * limit)
            .limit(limit)
        )

        return {
            "success": True,
            "count": len(items),
            "total": total,
            "page": page,
            "limit": limit,
            "total_pages": (total + limit - 1) // limit,
            "reviews": [serialize_review(item) for item in items],
        }

    except PyMongoError as exc:
        logger.exception("MongoDB error while retrieving customer reviews.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve reviews right now. Please try again later.",
        ) from exc
