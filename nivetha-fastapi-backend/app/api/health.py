
import logging

from fastapi import APIRouter, HTTPException
from pymongo.errors import PyMongoError

from app.db.mongo import check_mongodb

logger = logging.getLogger(__name__)

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
    """Check whether MongoDB is reachable."""
    try:
        check_mongodb()

        return {
            "success": True,
            "message": "MongoDB connected",
        }

    except PyMongoError as exc:
        logger.exception("MongoDB health check failed.")

        raise HTTPException(
            status_code=503,
            detail={
                "success": False,
                "message": "MongoDB connection failed",
            },
        ) from exc
