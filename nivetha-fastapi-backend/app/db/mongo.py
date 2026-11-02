import logging
from functools import lru_cache

import pymongo
from pymongo import ASCENDING, DESCENDING
from pymongo.errors import PyMongoError

from app.core.config import settings

logger = logging.getLogger(__name__)


@lru_cache(maxsize=1)
def get_mongodb_client() -> pymongo.MongoClient:
    """Create MongoDB client with connection pooling and timeouts."""

    mongodb_uri = settings.mongodb_uri_value

    if not mongodb_uri:
        raise RuntimeError(
            "MONGODB_URI is not configured. Set it in the application environment."
        )

    return pymongo.MongoClient(
        mongodb_uri,
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=10000,
        maxPoolSize=100,
        minPoolSize=10,
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

    try:
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
    except PyMongoError as exc:
        logger.warning("Customer index creation notice: %s", exc)


def create_application_indexes() -> None:
    """Create optimized indexes for application collections."""

    try:
        # Bookings indexes
        customer_db["bookings"].create_index(
            [
                ("customer_id", ASCENDING),
                ("created_at", DESCENDING),
            ],
            name="customer_bookings_created_at",
        )
        customer_db["bookings"].create_index(
            [
                ("status", ASCENDING),
                ("event_date", DESCENDING),
            ],
            name="bookings_status_event_date",
        )

        # Notifications indexes
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

        # Foods indexes (Supports category filtering & sorted lookup)
        customer_db["foods"].create_index(
            [
                ("is_available", ASCENDING),
                ("category", ASCENDING),
                ("name", ASCENDING),
            ],
            name="foods_availability_category_name",
        )

        # Reviews indexes
        customer_db["reviews"].create_index(
            [
                ("customer_id", ASCENDING),
                ("created_at", DESCENDING),
            ],
            name="reviews_customer_created_at",
        )
        customer_db["reviews"].create_index(
            [("created_at", DESCENDING)],
            name="reviews_created_at_desc",
        )

    except PyMongoError as exc:
        logger.warning("Application index creation notice: %s", exc)


def create_login_rate_limit_index() -> None:
    """Create a TTL index for expired login rate-limit buckets."""

    try:
        customer_db["login_rate_limits"].create_index(
            [("expires_at", ASCENDING)],
            expireAfterSeconds=0,
            name="login_rate_limits_ttl",
        )
    except PyMongoError as exc:
        logger.warning("Rate limit TTL index creation notice: %s", exc)


def close_mongodb() -> None:
    """Close MongoDB connection safely."""

    if get_mongodb_client.cache_info().currsize:
        try:
            client = get_mongodb_client()
            client.close()
        except Exception as exc:
            logger.warning("Error closing MongoDB connection: %s", exc)
        finally:
            get_mongodb_client.cache_clear()