
import logging

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
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


# Customer: View own details
@router.get("/me")
def get_current_customer_details(
    customer: dict = Depends(get_current_customer),
):
    return {
        "success": True,
        "customer": serialize_customer(customer),
    }


# Owner: View all customers
@router.get("/", summary="Owner - Get all customers")
def get_all_customers(
    owner: dict = Depends(get_current_owner),
):
    try:
        customers = list(
            customers_collection.find().sort("_id", -1)
        )

        return {
            "success": True,
            "count": len(customers),
            "customers": [
                serialize_customer(customer)
                for customer in customers
            ],
        }

    except PyMongoError as exc:
        logger.exception("Error retrieving customer list.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Unable to retrieve customers right now.",
        ) from exc


# Owner: View one customer by MongoDB ID
@router.get(
    "/{customer_id}",
    summary="Owner - Get customer details",
)
def get_customer_details(
    customer_id: str,
    owner: dict = Depends(get_current_owner),
):
    if not ObjectId.is_valid(customer_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid customer ID.",
        )

    try:
        customer = customers_collection.find_one(
            {"_id": ObjectId(customer_id)}
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
