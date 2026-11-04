
import logging
from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

notifications = customer_db["notifications"]


# ---------------------------------------------------------------------------
# AUTHENTICATION
# ---------------------------------------------------------------------------

async def get_current_user(
    token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = decode_access_token(token)

        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        role = payload.get("role")
        user_id = payload.get("sub")

        if role not in {"customer", "owner", "admin"}:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid user role",
            )

        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid user account",
            )

        if role == "customer" and not ObjectId.is_valid(user_id):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid customer ID",
            )

        return {
            "user_id": user_id,
            "role": role,
        }

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
        )


# ---------------------------------------------------------------------------
# NOTIFICATION OWNERSHIP
# ---------------------------------------------------------------------------

def get_notification_filter(
    user: dict,
    notification_id: Optional[str] = None,
) -> dict:
    role = user["role"]

    query = {}

    if notification_id:
        if not ObjectId.is_valid(notification_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid notification ID",
            )

        query["_id"] = ObjectId(notification_id)

    if role == "customer":
        query["recipient_role"] = "customer"
        query["customer_id"] = user["user_id"]

    elif role == "owner":
        query["recipient_role"] = "owner"

    elif role == "admin":
        query["recipient_role"] = {"$in": ["owner", "admin"]}

    return query


# ---------------------------------------------------------------------------
# SERIALIZER
# ---------------------------------------------------------------------------

def serialize_notification(notification: dict) -> dict:
    created_at = notification.get("created_at")

    return {
        "id": str(notification["_id"]),
        "recipient_role": notification.get("recipient_role"),
        "customer_id": (
            str(notification["customer_id"])
            if isinstance(notification.get("customer_id"), ObjectId)
            else notification.get("customer_id")
        ),
        "booking_id": notification.get("booking_id"),
        "title": notification.get("title", ""),
        "message": notification.get("message", ""),
        "is_read": notification.get("is_read", False),
        "created_at": (
            created_at.isoformat()
            if isinstance(created_at, datetime)
            else created_at
        ),
    }


# ---------------------------------------------------------------------------
# GET MY NOTIFICATIONS
# GET /api/v1/notifications/my-notifications
# ---------------------------------------------------------------------------

@router.get("/my-notifications")
async def get_my_notifications(
    unread_only: bool = False,
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    user: dict = Depends(get_current_user),
):
    try:
        query = get_notification_filter(user)

        if unread_only:
            query["is_read"] = False

        total = await notifications.count_documents(query)

        cursor = (
            notifications.find(query)
            .sort("created_at", -1)
            .skip((page - 1) * limit)
            .limit(limit)
        )

        notification_list = [
            serialize_notification(item)
            async for item in cursor
        ]

        return {
            "success": True,
            "total": total,
            "page": page,
            "limit": limit,
            "total_pages": (total + limit - 1) // limit,
            "notifications": notification_list,
        }

    except PyMongoError:
        logger.exception("Failed to fetch notifications")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch notifications",
        )


# ---------------------------------------------------------------------------
# GET UNREAD NOTIFICATION COUNT
# GET /api/v1/notifications/unread-count
# ---------------------------------------------------------------------------

@router.get("/unread-count")
async def get_unread_count(
    user: dict = Depends(get_current_user),
):
    try:
        query = get_notification_filter(user)
        query["is_read"] = False

        count = await notifications.count_documents(query)

        return {
            "success": True,
            "unread_count": count,
        }

    except PyMongoError:
        logger.exception("Failed to count unread notifications")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to get unread notification count",
        )


# ---------------------------------------------------------------------------
# MARK SINGLE NOTIFICATION AS READ
# PATCH /api/v1/notifications/{notification_id}/read
# ---------------------------------------------------------------------------

@router.patch("/{notification_id}/read")
async def mark_notification_as_read(
    notification_id: str,
    user: dict = Depends(get_current_user),
):
    try:
        query = get_notification_filter(user, notification_id)

        updated = await notifications.find_one_and_update(
            query,
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.now(timezone.utc),
                }
            },
            return_document=True,
        )

        if not updated:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Notification not found",
            )

        return {
            "success": True,
            "message": "Notification marked as read",
            "notification": serialize_notification(updated),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to mark notification as read")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notification",
        )


# ---------------------------------------------------------------------------
# MARK ALL NOTIFICATIONS AS READ
# PATCH /api/v1/notifications/read-all
# ---------------------------------------------------------------------------

@router.patch("/read-all")
async def mark_all_notifications_as_read(
    user: dict = Depends(get_current_user),
):
    try:
        query = get_notification_filter(user)
        query["is_read"] = False

        result = await notifications.update_many(
            query,
            {
                "$set": {
                    "is_read": True,
                    "read_at": datetime.now(timezone.utc),
                }
            },
        )

        return {
            "success": True,
            "message": "All notifications marked as read",
            "updated_count": result.modified_count,
        }

    except PyMongoError:
        logger.exception("Failed to mark all notifications as read")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notifications",
        )


# ---------------------------------------------------------------------------
# DELETE SINGLE NOTIFICATION
# DELETE /api/v1/notifications/{notification_id}
# ---------------------------------------------------------------------------

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    user: dict = Depends(get_current_user),
):
    try:
        query = get_notification_filter(user, notification_id)

        result = await notifications.delete_one(query)

        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Notification not found",
            )

        return {
            "success": True,
            "message": "Notification deleted successfully",
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to delete notification")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to delete notification",
        )
