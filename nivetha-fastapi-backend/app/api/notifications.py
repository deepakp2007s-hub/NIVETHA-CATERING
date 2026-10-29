
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

router = APIRouter(prefix="/notifications", tags=["Notifications"])
bearer_scheme = HTTPBearer(auto_error=False)

notifications_collection = customer_db["notifications"]


def get_token_payload(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
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


def get_customer_id(payload: dict = Depends(get_token_payload)) -> str:
    if payload.get("role") != "customer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Customer account required.",
        )

    customer_id = payload.get("sub")

    if not isinstance(customer_id, str) or not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer token.",
        )

    return customer_id


def require_owner(payload: dict = Depends(get_token_payload)) -> dict:
    if payload.get("role") != "owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Owner access required.",
        )

    return payload


def recipient_query(recipient_type: str) -> dict:
    return {
        "$or": [
            {"recipient_type": recipient_type},
            {
                "recipient_role": recipient_type,
                "recipient_type": {"$exists": False},
            },
        ]
    }


def serialize_notification(item: dict) -> dict:
    created_at = item.get("created_at")
    read_at = item.get("read_at")

    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    if isinstance(read_at, datetime):
        read_at = read_at.isoformat()

    return {
        "id": str(item["_id"]),
        "recipient_type": item.get(
            "recipient_type",
            item.get("recipient_role", "customer"),
        ),
        "title": item.get("title", ""),
        "message": item.get("message", ""),
        "type": item.get("type", "general"),
        "booking_id": item.get("booking_id"),
        "booking_object_id": item.get("booking_object_id"),
        "is_read": item.get("is_read", False),
        "created_at": created_at,
        "read_at": read_at,
    }


def list_notifications(query: dict, recipient_type: str) -> dict:
    items = list(
        notifications_collection.find(query)
        .sort("created_at", -1)
        .limit(100)
    )

    return {
        "success": True,
        "recipient_type": recipient_type,
        "count": len(items),
        "unread_count": sum(
            1 for item in items if not item.get("is_read", False)
        ),
        "notifications": [
            serialize_notification(item) for item in items
        ],
    }


@router.get("/")
def get_my_notifications(
    customer_id: str = Depends(get_customer_id),
):
    try:
        return list_notifications(
            {
                "$and": [
                    recipient_query("customer"),
                    {"customer_id": customer_id},
                ]
            },
            "customer",
        )
    except PyMongoError as exc:
        logger.exception("Unable to retrieve customer notifications.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load notifications.",
        ) from exc


@router.get("/owner")
def get_owner_notifications(
    _: dict = Depends(require_owner),
):
    try:
        return list_notifications(
            recipient_query("owner"),
            "owner",
        )
    except PyMongoError as exc:
        logger.exception("Unable to retrieve owner notifications.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to load notifications.",
        ) from exc


@router.patch("/read-all")
def mark_all_customer_notifications_as_read(
    customer_id: str = Depends(get_customer_id),
):
    try:
        result = notifications_collection.update_many(
            {
                "$and": [
                    recipient_query("customer"),
                    {"customer_id": customer_id},
                    {"is_read": {"$ne": True}},
                ]
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
    except PyMongoError as exc:
        logger.exception("Unable to mark customer notifications as read.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notifications.",
        ) from exc


@router.patch("/{notification_id}/read")
def mark_customer_notification_as_read(
    notification_id: str,
    customer_id: str = Depends(get_customer_id),
):
    if not ObjectId.is_valid(notification_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid notification ID.",
        )

    try:
        result = notifications_collection.update_one(
            {
                "_id": ObjectId(notification_id),
                "$and": [
                    recipient_query("customer"),
                    {"customer_id": customer_id},
                ],
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
    except PyMongoError as exc:
        logger.exception("Unable to mark customer notification as read.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notification.",
        ) from exc


@router.patch("/owner/read-all")
def mark_all_owner_notifications_as_read(
    _: dict = Depends(require_owner),
):
    try:
        result = notifications_collection.update_many(
            {
                "$and": [
                    recipient_query("owner"),
                    {"is_read": {"$ne": True}},
                ]
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
            "message": "Owner notifications marked as read.",
            "updated_count": result.modified_count,
        }
    except PyMongoError as exc:
        logger.exception("Unable to mark owner notifications as read.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update owner notifications.",
        ) from exc


@router.patch("/owner/{notification_id}/read")
def mark_owner_notification_as_read(
    notification_id: str,
    _: dict = Depends(require_owner),
):
    if not ObjectId.is_valid(notification_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid notification ID.",
        )

    try:
        result = notifications_collection.update_one(
            {
                "_id": ObjectId(notification_id),
                "$and": [recipient_query("owner")],
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
            "message": "Owner notification marked as read.",
        }
    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Unable to mark owner notification as read.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update notification.",
        ) from exc
