from functools import lru_cache

import pymongo
from pymongo import ASCENDING, DESCENDING

from app.core.config import settings


@lru_cache(maxsize=1)
def get_mongodb_client() -> pymongo.MongoClient:
    """Create MongoDB client only when database access is required."""

    mongodb_uri = settings.mongodb_uri_value

    if not mongodb_uri:
        raise RuntimeError(
            "MONGODB_URI is not configured. Set it in the application environment."
        )

    return pymongo.MongoClient(
        mongodb_uri,
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=10000,
        retryWrites=True,
        tz_aware=True,
    )


class LazyCollection:
    """Resolve a MongoDB collection only when an operation is requested."""

    def __init__(self, database, collection_name: str):
        self.database = database
        self.collection_name = collection_name

    def __getattr__(self, name):
        collection = self.database.get_collection(self.collection_name)
        return getattr(collection, name)


class LazyDatabase:
    """Resolve MongoDB database and collections on demand."""

    def __init__(self, database_name: str):
        self.database_name = database_name

    def get_database(self):
        return get_mongodb_client()[self.database_name]

    def get_collection(self, collection_name: str):
        return self.get_database()[collection_name]

    def __getitem__(self, collection_name: str):
        return LazyCollection(self, collection_name)


customer_db = LazyDatabase(settings.CUSTOMER_DATABASE_NAME)

owner_db = LazyDatabase(settings.OWNER_DATABASE_NAME)


def check_mongodb() -> bool:
    """Check whether MongoDB is reachable."""

    get_mongodb_client().admin.command("ping")
    return True


def create_customer_indexes() -> None:
    """Create unique customer email and phone indexes."""

    customers = customer_db["customers"]

    customers.create_index(
        [("email", ASCENDING)],
        unique=True,
        name="unique_customer_email_v2",
        partialFilterExpression={"email": {"$type": "string"}},
    )

    customers.create_index(
        [("phone", ASCENDING)],
        unique=True,
        name="unique_customer_phone_v2",
        partialFilterExpression={"phone": {"$type": "string"}},
    )


def create_application_indexes() -> None:
    """Create indexes for application collections."""

    customer_db["bookings"].create_index(
        [
            ("customer_id", ASCENDING),
            ("created_at", DESCENDING),
        ],
        name="customer_bookings_created_at",
    )

    customer_db["notifications"].create_index(
        [
            ("recipient_role", ASCENDING),
            ("created_at", DESCENDING),
        ],
        name="notifications_role_created_at",
    )

    customer_db["notifications"].create_index(
        [
            ("customer_id", ASCENDING),
            ("created_at", DESCENDING),
        ],
        name="notifications_customer_created_at",
    )

    customer_db["foods"].create_index(
        [
            ("is_available", ASCENDING),
            ("created_at", DESCENDING),
        ],
        name="foods_availability_created_at",
    )

    customer_db["reviews"].create_index(
        [
            ("customer_id", ASCENDING),
            ("created_at", DESCENDING),
        ],
        name="reviews_customer_created_at",
    )


def close_mongodb() -> None:
    """Close MongoDB connection safely."""

    if get_mongodb_client.cache_info().currsize:
        client = get_mongodb_client()
        client.close()
        get_mongodb_client.cache_clear()
