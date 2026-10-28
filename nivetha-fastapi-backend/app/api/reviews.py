
import logging
from datetime import datetime, timezone
from typing import Any

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field, field_validator
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(prefix="/reviews", tags=["Customer Reviews"])
bearer_scheme = HTTPBearer(auto_error=False)


class ReviewRequest(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: str = Field(min_length=3, max_length=1000)

    @field_validator("comment")
    @classmethod
    def validate_comment(cls, value: str) -> str:
        value = value.strip()

        if len(value) < 3:
            raise ValueError("Comment must contain at least 3 characters.")

        return value


def get_customer_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to submit a review.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        if not isinstance(payload, dict):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid access token.",
            )

        customer_id = payload.get("sub")

        if payload.get("role") != "customer":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customer account required.",
            )

        if not customer_id or not ObjectId.is_valid(customer_id):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid access token.",
            )

        return str(customer_id)

    except HTTPException:
        raise

    except (jwt.InvalidTokenError, ValueError, TypeError):
        logger.warning("Review request rejected because the access token is invalid.")

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )


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


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_review(
    data: ReviewRequest,
    customer_id: str = Depends(get_customer_id),
):
    try:
        customer = customer_db["customers"].find_one(
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
            "created_at": datetime.now(timezone.utc),
        }

        result = customer_db["reviews"].insert_one(review)

        saved_review = {
            "_id": result.inserted_id,
            **review,
        }

        logger.info("Review created successfully for customer %s", customer_id)

        return {
            "success": True,
            "message": "Review submitted successfully.",
            "review": serialize_review(saved_review),
        }

    except HTTPException:
        raise

    except PyMongoError:
        logger.exception("MongoDB error while creating a review.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to save review right now. Please try again later.",
        )

    except Exception:
        logger.exception("Unexpected error while creating a review.")

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while submitting the review.",
        )


@router.get("/my-reviews")
def get_my_reviews(
    customer_id: str = Depends(get_customer_id),
):
    try:
        reviews = list(
            customer_db["reviews"]
            .find({"customer_id": customer_id})
            .sort("created_at", -1)
        )

        return {
            "success": True,
            "count": len(reviews),
            "reviews": [serialize_review(review) for review in reviews],
        }

    except PyMongoError:
        logger.exception("MongoDB error while retrieving customer reviews.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve reviews right now. Please try again later.",
        )

    except Exception:
        logger.exception("Unexpected error while retrieving customer reviews.")

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while retrieving reviews.",
        )
