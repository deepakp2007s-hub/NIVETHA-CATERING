import logging

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pymongo.errors import PyMongoError

from app.api.profiles import (
    customers_collection,
    get_current_customer,
    get_current_owner,
    serialize_customer,
)

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)


# --------------------------------------------------
# CUSTOMER: VIEW OWN DETAILS
# --------------------------------------------------


@router.get("/me", summary="Customer - Get personal profile")
def get_current_customer_details(
    customer: dict = Depends(get_current_customer),
):
    return {
        "success": True,
        "customer": serialize_customer(customer),
    }


# --------------------------------------------------
# OWNER / ADMIN: VIEW ALL CUSTOMERS (PAGINATED)
# --------------------------------------------------


@router.get("/", summary="Owner/Admin - Get all customers")
def get_all_customers(
    skip: int = Query(0, ge=0, description="Pagination skip offset"),
    limit: int = Query(50, ge=1, le=200, description="Pagination limit size"),
    staff: dict = Depends(get_current_owner),
):
    try:
        total = customers_collection.count_documents({})
        
        # Exclude password_hash projection at DB layer for security & speed
        customers = list(
            customers_collection.find({}, {"password_hash": 0})
            .sort("_id", -1)
            .skip(skip)
            .limit(limit)
        )

        return {
            "success": True,
            "total": total,
            "count": len(customers),
            "customers": [serialize_customer(customer) for customer in customers],
        }

    except PyMongoError as exc:
        logger.exception("Error retrieving customer list.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve customers right now.",
        ) from exc


# --------------------------------------------------
# OWNER / ADMIN: VIEW CUSTOMER BY ID
# --------------------------------------------------


@router.get(
    "/{customer_id}",
    summary="Owner/Admin - Get customer details",
)
def get_customer_details(
    customer_id: str,
    staff: dict = Depends(get_current_owner),
):
    if not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid customer ID format.",
        )

    try:
        customer = customers_collection.find_one(
            {"_id": ObjectId(customer_id)},
            {"password_hash": 0},
        )

        if customer is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Customer not found.",
            )

        return {
            "success": True,
            "customer": serialize_customer(customer),
        }

    except HTTPException:
        raise
    except PyMongoError as exc:
        logger.exception("Error retrieving customer details.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve customer details right now.",
        ) from exc