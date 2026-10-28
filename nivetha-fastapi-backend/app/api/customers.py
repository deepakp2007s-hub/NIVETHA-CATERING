
from fastapi import APIRouter, Depends

from app.api.profiles import get_current_customer, serialize_customer


router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)


@router.get("/me")
def get_current_customer_details(
    customer: dict = Depends(get_current_customer),
):
    """Return details for the authenticated customer."""
    return {
        "success": True,
        "customer": serialize_customer(customer),
    }
