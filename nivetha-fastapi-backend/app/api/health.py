import logging
from typing import Any

from fastapi import APIRouter, HTTPException, status
from pymongo.errors import PyMongoError

from app.db.mongo import check_mongodb

logger = logging.getLogger(__name__)

router = APIRouter(prefix="", tags=["Health"])


@router.get("/health", summary="Basic API Health Check")
def health_check() -> dict[str, Any]:
    """Check whether the FastAPI service is running."""
    return {
        "success": True,
        "status": "healthy",
        "message": "Nivetha Catering API is running",
    }


@router.get("/health/database", summary="MongoDB Connection Health Check")
def database_health_check() -> dict[str, Any]:
    """Check whether MongoDB is reachable."""
    try:
        check_mongodb()

        return {
            "success": True,
            "status": "healthy",
            "message": "MongoDB connected successfully",
        }

    except PyMongoError as exc:
        logger.exception("MongoDB health check failed.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="MongoDB connection failed.",
        ) from exc

    except RuntimeError as exc:
        logger.exception("MongoDB configuration error.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database configuration unavailable.",
        ) from exc

    except Exception as exc:
        logger.exception("Unexpected database health check error.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database health check unavailable.",
        ) from exc