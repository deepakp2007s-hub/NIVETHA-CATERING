import logging
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.cache import clear_cache
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
# APPLICATION CONFIGURATION
# ---------------------------------------------------------------------------

API_PREFIX = settings.API_V1_PREFIX.rstrip("/")


def get_cors_origins() -> list[str]:
    origins = getattr(settings, "cors_origins_list", [])

    if isinstance(origins, str):
        origins = origins.split(",")

    if not isinstance(origins, (list, tuple, set)):
        logger.warning("Invalid CORS origins configuration.")
        return []

    normalized_origins = []

    for origin in origins:
        if not isinstance(origin, str):
            continue

        origin = origin.strip().rstrip("/")

        if not origin:
            continue

        if origin == "*":
            logger.warning(
                "Wildcard CORS origin rejected because credentials are enabled."
            )
            continue

        normalized_origins.append(origin)

    return list(dict.fromkeys(normalized_origins))


# ---------------------------------------------------------------------------
# APPLICATION LIFESPAN
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting %s", settings.APP_NAME)
    clear_cache()

    try:
        await connect_to_mongo()
        app.state.database_ready = True

        logger.info("MongoDB initialization completed")

    except Exception:
        app.state.database_ready = False
        logger.exception("Application startup failed")
        raise

    try:
        yield

    finally:
        logger.info("Shutting down %s", settings.APP_NAME)
        clear_cache()

        try:
            await close_mongo_connection()
            app.state.database_ready = False

            logger.info("MongoDB connection closed")

        except Exception:
            logger.exception("MongoDB shutdown failed")


# ---------------------------------------------------------------------------
# FASTAPI APPLICATION
# ---------------------------------------------------------------------------

app = FastAPI(
    title=settings.APP_NAME,
    description=(
        "Nivetha Catering Customer and Owner Management API"
    ),
    version="2.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)


# ---------------------------------------------------------------------------
# CORS MIDDLEWARE
# ---------------------------------------------------------------------------

allowed_origins = get_cors_origins()

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins if allowed_origins else ["*"],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$|^https://.*\.vercel\.app$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# API ROUTERS
# ---------------------------------------------------------------------------

app.include_router(
    auth_router,
    prefix=f"{API_PREFIX}/auth",
    tags=["Authentication"],
)

app.include_router(
    bookings_router,
    prefix=API_PREFIX,
)

app.include_router(
    customers_router,
    prefix=API_PREFIX,
)

app.include_router(
    foods_router,
    prefix=f"{API_PREFIX}/foods",
)

app.include_router(
    profiles_router,
    prefix=API_PREFIX,
)

app.include_router(
    notifications_router,
    prefix=API_PREFIX,
)

app.include_router(
    reports_router,
    prefix=API_PREFIX,
)

app.include_router(
    reviews_router,
    prefix=API_PREFIX,
)

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
# RATE LIMIT / NOT FOUND / SERVER ERROR HANDLERS
# ---------------------------------------------------------------------------

@app.exception_handler(429)
async def rate_limit_handler(
    request: Request,
    exc,
):
    detail = getattr(exc, "detail", "Too many requests. Please try again later.")
    return JSONResponse(
        status_code=429,
        content={
            "success": False,
            "message": detail,
            "path": request.url.path,
        },
    )


@app.exception_handler(404)
async def not_found_handler(
    request: Request,
    exc,
):
    return JSONResponse(
        status_code=404,
        content={
            "success": False,
            "message": "API endpoint not found",
            "path": request.url.path,
        },
    )


@app.exception_handler(500)
async def internal_server_error_handler(
    request: Request,
    exc,
):
    logger.error(
        "Internal server error on %s",
        request.url.path,
        exc_info=(
            type(exc),
            exc,
            exc.__traceback__,
        ),
    )

    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(
    request: Request,
    exc: Exception,
):
    logger.error(
        "Unhandled exception on %s",
        request.url.path,
        exc_info=(
            type(exc),
            exc,
            exc.__traceback__,
        ),
    )

    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "An unexpected server error occurred",
        },
    )