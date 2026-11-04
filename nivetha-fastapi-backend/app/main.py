
import logging
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.db.mongo import (
    connect_to_mongo,
    close_mongo_connection,
)

from app.api.auth import router as auth_router
from app.api.bookings import router as bookings_router
from app.api.customers import router as customers_router
from app.api.foods import router as foods_router
from app.api.health import router as health_router
from app.api.notifications import router as notifications_router
from app.api.profiles import router as profiles_router
from app.api.reports import router as reports_router
from app.api.reviews import router as reviews_router


# ---------------------------------------------------------------------------
# LOGGING
# ---------------------------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)

logger = logging.getLogger("nivetha_catering")


# ---------------------------------------------------------------------------
# APPLICATION LIFESPAN
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting Nivetha Catering API")

    try:
        await connect_to_mongo()
        logger.info("MongoDB initialization completed")
    except Exception:
        logger.exception("MongoDB initialization failed")
        raise

    yield

    logger.info("Shutting down Nivetha Catering API")

    try:
        await close_mongo_connection()
    except Exception:
        logger.exception("MongoDB shutdown error")


# ---------------------------------------------------------------------------
# FASTAPI APPLICATION
# ---------------------------------------------------------------------------

app = FastAPI(
    title=settings.APP_NAME,
    description="Nivetha Catering Customer and Owner Management API",
    version="2.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)


# ---------------------------------------------------------------------------
# CORS CONFIGURATION
# ---------------------------------------------------------------------------

allowed_origins = getattr(
    settings,
    "cors_origins_list",
    [
        "http://localhost:5173",
        "http://localhost:3000",
    ],
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)


# ---------------------------------------------------------------------------
# API ROUTERS
# ---------------------------------------------------------------------------

API_PREFIX = settings.API_V1_PREFIX.rstrip("/")


# Authentication
app.include_router(
    auth_router,
    prefix=f"{API_PREFIX}/auth",
    tags=["Authentication"],
)

# Bookings
# bookings.py already contains prefix="/bookings"
app.include_router(
    bookings_router,
    prefix=API_PREFIX,
)

# Customers
# customers.py already contains prefix="/customers"
app.include_router(
    customers_router,
    prefix=API_PREFIX,
)

# Foods
# foods.py has no router prefix
app.include_router(
    foods_router,
    prefix=f"{API_PREFIX}/foods",
)

# Profiles
# profiles.py already contains prefix="/profile"
app.include_router(
    profiles_router,
    prefix=API_PREFIX,
)

# Notifications
# notifications.py already contains prefix="/notifications"
app.include_router(
    notifications_router,
    prefix=API_PREFIX,
)

# Reports
# reports.py already contains prefix="/reports"
app.include_router(
    reports_router,
    prefix=API_PREFIX,
)

# Reviews
# reviews.py already contains prefix="/reviews"
app.include_router(
    reviews_router,
    prefix=API_PREFIX,
)

# Health
# health.py already contains prefix="/health"
app.include_router(
    health_router,
    prefix=API_PREFIX,
)


# ---------------------------------------------------------------------------
# ROOT ENDPOINT
# GET /
# ---------------------------------------------------------------------------

@app.get("/", tags=["Root"])
async def root():
    return {
        "success": True,
        "message": "Welcome to Nivetha Catering API",
        "app_name": settings.APP_NAME,
        "version": app.version,
        "environment": settings.APP_ENV,
        "docs": "/docs",
        "health": f"{API_PREFIX}/health/",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# API STATUS
# GET /api/v1/status
# ---------------------------------------------------------------------------

@app.get(
    f"{API_PREFIX}/status",
    tags=["System"],
)
async def api_status():
    return {
        "success": True,
        "status": "running",
        "service": settings.APP_NAME,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# GLOBAL HTTP EXCEPTION HANDLER
# ---------------------------------------------------------------------------

@app.exception_handler(404)
async def not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={
            "success": False,
            "message": "API endpoint not found",
            "path": request.url.path,
        },
    )


# ---------------------------------------------------------------------------
# GLOBAL SERVER ERROR HANDLER
# ---------------------------------------------------------------------------

@app.exception_handler(500)
async def internal_server_error_handler(request, exc):
    logger.exception(
        "Internal server error on %s",
        request.url.path,
    )

    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
        },
    )
