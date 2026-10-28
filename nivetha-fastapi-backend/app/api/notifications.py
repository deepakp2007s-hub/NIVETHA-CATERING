
from datetime import datetime, timezone

import jwt
from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.errors import PyMongoError
from pydantic import BaseModel, Field

from app.core.security import decode_access_token
from app.db.mongo import customer_db


router = APIRouter(
    prefix="/notifications",
    tags=["Customer Notifications"],
)

bearer_scheme = HTTPBearer(auto_error=False)


def get_customer_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please log in to view notifications.",
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


class NotificationCreate(BaseModel):
    title: str = Field(min_length=1, max_length=150)
    message: str = Field(min_length=1, max_length=1000)
    booking_id: str | None = None


def serialize_notification(notification: dict) -> dict:
    return {
        "id": str(notification["_id"]),
        "title": notification.get("title", ""),
        "message": notification.get("message", ""),
        "booking_id": notification.get("booking_id"),
        "is_read": notification.get("is_read", False),
        "created_at": notification.get("created_at"),
    }


@router.get("/")
def get_my_notifications(
    customer_id: str = Depends(get_customer_id),
):
    try:
        notifications = list(
            customer_db["notifications"]
            .find({"customer_id": customer_id})
            .sort("created_at", -1)
            .limit(100)
        )

        unread_count = sum(
            1 for notification in notifications
            if not notification.get("is_read", False)
        )

        return {
            "success": True,
            "count": len(notifications),
            "unread_count": unread_count,
            "notifications": [
                serialize_notification(notification)
                for notification in notifications
            ],
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve notifications right now.",
        )


@router.patch("/{notification_id}/read")
def mark_notification_as_read(
    notification_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(notification_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid notification ID.",
        )

    try:
        result = customer_db["notifications"].update_one(
            {
                "_id": ObjectId(notification_id),
                "customer_id": customer_id,
            },
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.now(timezone.utc),
                }
            },
        )

        if result.matched_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Notification not found.",
            )

        return {
            "success": True,
            "message": "Notification marked as read.",
        }

    except HTTPException:
        raise
    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notification right now.",
        )


@router.patch("/read-all")
def mark_all_notifications_as_read(
    customer_id: str = Depends(get_customer_id),
):
    try:
        result = customer_db["notifications"].update_many(
            {
                "customer_id": customer_id,
                "is_read": {"$ne": True},
            },
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.now(timezone.utc),
                }
            },
        )

        return {
            "success": True,
            "message": "Notifications marked as read.",
            "updated_count": result.modified_count,
        }

    except PyMongoError:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notifications right now.",
        )
