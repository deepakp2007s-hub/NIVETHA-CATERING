
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pymongo.errors import PyMongoError

from app.core.config import settings
from app.api.auth import router as auth_router
from app.api.customers import router as customers_router
from app.api.profiles import router as profiles_router
from app.api.foods import router as foods_router
from app.api.bookings import router as bookings_router
from app.api.reviews import router as reviews_router
from app.api.reports import router as reports_router
from app.api.notifications import router as notifications_router

from app.db.mongo import (
    check_mongodb,
    create_customer_indexes,
    create_application_indexes,
    close_mongodb,
)


logger = logging.getLogger(__name__)

API_PREFIX = "/api/v1"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Check MongoDB and initialize application indexes."""
    try:
        check_mongodb()
        create_customer_indexes()
        create_application_indexes()

        logger.info(
            "MongoDB connected and application indexes initialized."
        )
        yield
    finally:
        close_mongodb()
        logger.info("MongoDB client closed.")


app = FastAPI(
    title=settings.APP_NAME,
    description="Shared backend for Nivetha Customer and Anna Owner Apps",
    version=settings.APP_VERSION,
    lifespan=lifespan,
)


# Centralized CORS configuration from app/core/config.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)


# Register API routers.
app.include_router(auth_router, prefix=API_PREFIX)
app.include_router(customers_router, prefix=API_PREFIX)
app.include_router(profiles_router, prefix=API_PREFIX)
app.include_router(foods_router, prefix=API_PREFIX)
app.include_router(bookings_router, prefix=API_PREFIX)
app.include_router(reviews_router, prefix=API_PREFIX)
app.include_router(reports_router, prefix=API_PREFIX)
app.include_router(notifications_router, prefix=API_PREFIX)


@app.get("/", tags=["Health"])
def root():
    return {
        "success": True,
        "message": "Nivetha Catering API is running",
    }


@app.get(f"{API_PREFIX}/health", tags=["Health"])
def health_check():
    return {
        "success": True,
        "message": "Nivetha Catering API is running",
    }


@app.get(f"{API_PREFIX}/health/database", tags=["Health"])
def database_health_check():
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
