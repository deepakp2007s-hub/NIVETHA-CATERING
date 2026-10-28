
from fastapi import APIRouter, HTTPException
from pymongo.errors import PyMongoError

from app.db.mongo import check_mongodb


router = APIRouter(tags=["Health"])


@router.get("/health")
def health_check():
    """Check whether the FastAPI service is running."""
    return {
        "success": True,
        "message": "Nivetha Catering API is running",
    }


@router.get("/health/database")
def database_health_check():
    """Check the MongoDB connection."""
    try:
        check_mongodb()

        return {
            "success": True,
            "message": "MongoDB connected",
        }

    except PyMongoError:
        raise HTTPException(
            status_code=503,
            detail={
                "success": False,
                "message": "MongoDB connection failed",
            },
        )
