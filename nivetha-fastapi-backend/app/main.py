
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pymongo.errors import PyMongoError

from app.api.auth import router as auth_router
from app.api.profiles import router as profiles_router
from app.api.foods import router as foods_router
from app.api.bookings import router as bookings_router
from app.api.reviews import router as reviews_router
from app.api.reports import router as reports_router
from app.api.notifications import router as notifications_router

from app.db.mongo import (
    check_mongodb,
    create_customer_indexes,
    close_mongodb,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    check_mongodb()
    create_customer_indexes()

    yield

    close_mongodb()


app = FastAPI(
    title="Nivetha Catering API",
    description="Backend API for Nivetha Catering Service",
    version="1.0.0",
    lifespan=lifespan,
)


allowed_origins = [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8080",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5173",
    "https://nivetha-catering.vercel.app",
    "https://nivetha-catering-kjh1.vercel.app",
]


app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Register API routers
app.include_router(auth_router, prefix="/api/v1")
app.include_router(profiles_router, prefix="/api/v1")
app.include_router(foods_router, prefix="/api/v1")
app.include_router(bookings_router, prefix="/api/v1")
app.include_router(reviews_router, prefix="/api/v1")
app.include_router(reports_router, prefix="/api/v1")
app.include_router(notifications_router, prefix="/api/v1")


@app.get("/", tags=["Health"])
def root():
    return {
        "success": True,
        "message": "Nivetha Catering API is running",
    }


@app.get("/api/v1/health", tags=["Health"])
def health_check():
    return {
        "success": True,
        "message": "Nivetha Catering API is running",
    }


@app.get("/api/v1/health/database", tags=["Health"])
def database_health_check():
    try:
        check_mongodb()
        return {
            "success": True,
            "message": "MongoDB connected",
        }

    except PyMongoError as exc:
        raise HTTPException(
            status_code=503,
            detail={
                "success": False,
                "message": "MongoDB connection failed",
            },
        ) from exc
