import logging

from fastapi import APIRouter, HTTPException, status
from pymongo.errors import PyMongoError

from app.db.mongo import check_mongodb

logger = logging.getLogger(__name__)

router = APIRouter(tags=["Health"])


@router.get("/health")
def health_check():
    """Check whether the FastAPI service is running."""

    return {
        "success": True,
        "status": "healthy",
        "message": "Nivetha Catering API is running",
    }


@router.get("/health/database")
def database_health_check():
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
            detail={
                "success": False,
                "status": "unhealthy",
                "message": "MongoDB connection failed",
            },
        ) from exc

    except RuntimeError as exc:
        logger.exception("MongoDB configuration error.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "success": False,
                "status": "unhealthy",
                "message": "Database configuration unavailable",
            },
        ) from exc

    except Exception as exc:
        logger.exception("Unexpected database health check error.")

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "success": False,
                "status": "unhealthy",
                "message": "Database health check unavailable",
            },
        ) from exc
