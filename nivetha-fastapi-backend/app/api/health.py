
import logging
import time
from datetime import datetime, timezone

from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

from app.core.config import settings
from app.db.mongo import get_client, get_database


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/health",
    tags=["Health"],
)


# ---------------------------------------------------------------------------
# BASIC HEALTH CHECK
# GET /api/v1/health/
# ---------------------------------------------------------------------------

@router.get("/")
async def health_check():
    return {
        "success": True,
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "environment": settings.APP_ENV,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# DATABASE HEALTH CHECK
# GET /api/v1/health/database
# ---------------------------------------------------------------------------

@router.get("/database")
async def database_health_check():
    started_at = time.perf_counter()

    try:
        client = get_client()
        await client.admin.command("ping")

        response_time_ms = round(
            (time.perf_counter() - started_at) * 1000,
            2,
        )

        return {
            "success": True,
            "status": "connected",
            "database": settings.CUSTOMER_DATABASE_NAME,
            "response_time_ms": response_time_ms,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    except ServerSelectionTimeoutError:
        logger.exception("MongoDB server selection timed out")

        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "status": "disconnected",
                "database": settings.CUSTOMER_DATABASE_NAME,
                "message": "MongoDB server is not reachable",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )

    except PyMongoError:
        logger.exception("MongoDB health check failed")

        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "status": "error",
                "message": "Database health check failed",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )

    except Exception:
        logger.exception("Unexpected database health check error")

        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "status": "error",
                "message": "Unexpected health check error",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )


# ---------------------------------------------------------------------------
# DATABASE DETAILS
# GET /api/v1/health/database/details
# ---------------------------------------------------------------------------

@router.get("/database/details")
async def database_details():
    try:
        database = get_database()
        client = get_client()

        await client.admin.command("ping")

        collections = await database.list_collection_names()

        return {
            "success": True,
            "database": settings.CUSTOMER_DATABASE_NAME,
            "connection": "connected",
            "collections_count": len(collections),
            "collections": sorted(collections),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    except PyMongoError:
        logger.exception("Unable to retrieve database details")

        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "connection": "disconnected",
                "message": "Unable to retrieve database details",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )


# ---------------------------------------------------------------------------
# READINESS CHECK
# GET /api/v1/health/ready
# ---------------------------------------------------------------------------

@router.get("/ready")
async def readiness_check():
    try:
        client = get_client()
        await client.admin.command("ping")

        return {
            "success": True,
            "status": "ready",
            "message": "Application is ready to receive requests",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    except Exception:
        logger.exception("Application readiness check failed")

        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "status": "not_ready",
                "message": "Application dependencies are unavailable",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        )
