
import logging
from datetime import datetime, timezone
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from pymongo.errors import PyMongoError

from app.core.security import decode_access_token
from app.db.mongo import customer_db


logger = logging.getLogger(__name__)

router = APIRouter(prefix="/customers", tags=["Customers"])

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/customer/login"
)

customers = customer_db["customers"]
bookings = customer_db["bookings"]


# ---------------------------------------------------------------------------
# SCHEMAS
# ---------------------------------------------------------------------------

class CustomerUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    full_name: Optional[str] = Field(default=None, min_length=2, max_length=100)
    phone: Optional[str] = Field(default=None, min_length=10, max_length=15)
    email: Optional[EmailStr] = None


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
            detail="Invalid or expired token",
        )


# ---------------------------------------------------------------------------
# SERIALIZER
# ---------------------------------------------------------------------------

def serialize_customer(customer: dict) -> dict:
    if not customer:
        return {}

    return {
        "id": str(customer["_id"]),
        "full_name": customer.get("full_name") or customer.get("name", ""),
        "name": customer.get("name") or customer.get("full_name", ""),
        "email": customer.get("email", ""),
        "phone": customer.get("phone", ""),
        "created_at": (
            customer["created_at"].isoformat()
            if isinstance(customer.get("created_at"), datetime)
            else customer.get("created_at")
        ),
        "updated_at": (
            customer["updated_at"].isoformat()
            if isinstance(customer.get("updated_at"), datetime)
            else customer.get("updated_at")
        ),
    }


# ---------------------------------------------------------------------------
# GET ALL CUSTOMERS
# GET /api/v1/customers/
# ---------------------------------------------------------------------------

@router.get("/")
async def get_all_customers(
    search: Optional[str] = Query(default=None, max_length=100),
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    user: dict = Depends(require_owner_or_admin),
):
    try:
        query = {}

        if search and search.strip():
            search_text = search.strip()
            query["$or"] = [
                {"full_name": {"$regex": search_text, "$options": "i"}},
                {"name": {"$regex": search_text, "$options": "i"}},
                {"email": {"$regex": search_text, "$options": "i"}},
                {"phone": {"$regex": search_text, "$options": "i"}},
            ]

        total = await customers.count_documents(query)

        cursor = (
            customers.find(query)
            .sort("created_at", -1)
            .skip((page - 1) * limit)
            .limit(limit)
        )

        customer_list = [
            serialize_customer(customer)
            async for customer in cursor
        ]

        return {
            "success": True,
            "total": total,
            "page": page,
            "limit": limit,
            "total_pages": (total + limit - 1) // limit,
            "customers": customer_list,
        }

    except PyMongoError:
        logger.exception("Failed to fetch customers")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch customers",
        )


# ---------------------------------------------------------------------------
# GET CUSTOMER STATISTICS
# GET /api/v1/customers/stats
# ---------------------------------------------------------------------------

@router.get("/stats")
async def get_customer_stats(
    user: dict = Depends(require_owner_or_admin),
):
    try:
        total_customers = await customers.count_documents({})

        total_bookings = await bookings.count_documents({})

        active_customers = await bookings.distinct("customer_id")

        return {
            "success": True,
            "stats": {
                "total_customers": total_customers,
                "customers_with_bookings": len(active_customers),
                "total_bookings": total_bookings,
            },
        }

    except PyMongoError:
        logger.exception("Failed to fetch customer statistics")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch customer statistics",
        )


# ---------------------------------------------------------------------------
# GET SINGLE CUSTOMER
# GET /api/v1/customers/{customer_id}
# ---------------------------------------------------------------------------

@router.get("/{customer_id}")
async def get_customer(
    customer_id: str,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid customer ID",
        )

    try:
        customer_object_id = ObjectId(customer_id)

        customer = await customers.find_one({
            "_id": customer_object_id,
        })

        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found",
            )

        booking_count = await bookings.count_documents({
            "customer_id": customer_object_id,
        })

        result = serialize_customer(customer)
        result["total_bookings"] = booking_count

        return {
            "success": True,
            "customer": result,
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to fetch customer details")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to fetch customer details",
        )


# ---------------------------------------------------------------------------
# UPDATE CUSTOMER
# PATCH /api/v1/customers/{customer_id}
# ---------------------------------------------------------------------------

@router.patch("/{customer_id}")
async def update_customer(
    customer_id: str,
    data: CustomerUpdate,
    user: dict = Depends(require_owner_or_admin),
):
    if not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid customer ID",
        )

    update_data = data.model_dump(exclude_unset=True)

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one field is required",
        )

    if "full_name" in update_data:
        full_name = update_data["full_name"].strip()

        if len(full_name) < 2:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Customer name must contain at least 2 characters",
            )

        update_data["full_name"] = full_name
        update_data["name"] = full_name

    if "phone" in update_data:
        phone = update_data["phone"].strip()

        if not phone.isdigit():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Phone number must contain only digits",
            )

        update_data["phone"] = phone

    if "email" in update_data:
        update_data["email"] = str(update_data["email"]).strip().lower()

    try:
        customer_object_id = ObjectId(customer_id)

        existing = await customers.find_one({
            "_id": customer_object_id,
        })

        if not existing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found",
            )

        if "email" in update_data:
            duplicate_email = await customers.find_one({
                "email": update_data["email"],
                "_id": {"$ne": customer_object_id},
            })

            if duplicate_email:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Email already belongs to another customer",
                )

        if "phone" in update_data:
            duplicate_phone = await customers.find_one({
                "phone": update_data["phone"],
                "_id": {"$ne": customer_object_id},
            })

            if duplicate_phone:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Phone number already belongs to another customer",
                )

        update_data["updated_at"] = datetime.now(timezone.utc)

        await customers.update_one(
            {"_id": customer_object_id},
            {"$set": update_data},
        )

        updated_customer = await customers.find_one({
            "_id": customer_object_id,
        })

        return {
            "success": True,
            "message": "Customer updated successfully",
            "customer": serialize_customer(updated_customer),
        }

    except HTTPException:
        raise
    except PyMongoError:
        logger.exception("Failed to update customer")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to update customer",
        )
