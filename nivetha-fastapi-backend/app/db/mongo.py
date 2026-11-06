
import logging
from typing import Any, Optional

from motor.motor_asyncio import (
    AsyncIOMotorClient,
    AsyncIOMotorDatabase,
)
from pymongo.errors import OperationFailure, PyMongoError

from app.core.config import settings


logger = logging.getLogger("nivetha_catering.db")


# ---------------------------------------------------------------------
# DATABASE MANAGER
# ---------------------------------------------------------------------

class DatabaseManager:
    def __init__(self):
        self.client: Optional[AsyncIOMotorClient] = None


db_manager = DatabaseManager()


# ---------------------------------------------------------------------
# MONGODB CLIENT
# ---------------------------------------------------------------------

def get_client() -> AsyncIOMotorClient:
    if db_manager.client is None:
        db_manager.client = AsyncIOMotorClient(
            settings.MONGODB_URI,
            serverSelectionTimeoutMS=10000,
            connectTimeoutMS=10000,
            socketTimeoutMS=20000,
            maxPoolSize=50,
            minPoolSize=5,
            retryWrites=True,
        )

    return db_manager.client


# ---------------------------------------------------------------------
# DATABASE ACCESS
# ---------------------------------------------------------------------

def get_database() -> AsyncIOMotorDatabase:
    database_name = settings.CUSTOMER_DATABASE_NAME
    return get_client()[database_name]


def get_owner_database() -> AsyncIOMotorDatabase:
    database_name = settings.OWNER_DATABASE_NAME
    return get_client()[database_name]


# ---------------------------------------------------------------------
# LAZY DATABASE AND COLLECTION
# ---------------------------------------------------------------------

class LazyCollection:
    def __init__(self, database, collection_name: str):
        self.database = database
        self.collection_name = collection_name

    def __getattr__(self, name: str) -> Any:
        collection = self.database._get_db()[self.collection_name]
        return getattr(collection, name)


class LazyDatabase:
    def __init__(self, database_name_attribute: str):
        self.database_name_attribute = database_name_attribute

    def _get_db(self) -> AsyncIOMotorDatabase:
        database_name = getattr(
            settings,
            self.database_name_attribute,
        )

        return get_client()[database_name]

    def __getitem__(self, collection_name: str):
        return LazyCollection(self, collection_name)

    def __getattr__(self, name: str) -> Any:
        return getattr(self._get_db(), name)


customer_db = LazyDatabase("CUSTOMER_DATABASE_NAME")
owner_db = LazyDatabase("OWNER_DATABASE_NAME")


# ---------------------------------------------------------------------
# SAFE INDEX INITIALIZATION
# ---------------------------------------------------------------------

async def ensure_index(
    collection,
    keys: list[tuple],
    name: str,
    unique: bool = False,
    sparse: bool = False,
):
    requested_keys = list(keys)

    try:
        existing_indexes = await collection.index_information()

        for existing_name, existing in existing_indexes.items():
            existing_keys = list(existing.get("key", []))

            if existing_keys != requested_keys:
                continue

            existing_unique = existing.get("unique", False)
            existing_sparse = existing.get("sparse", False)

            if (
                existing_unique == unique
                and existing_sparse == sparse
            ):
                logger.info(
                    "Equivalent MongoDB index already exists: %s",
                    existing_name,
                )
            else:
                logger.warning(
                    "Existing index '%s' has different options. "
                    "Preserving existing index without modification.",
                    existing_name,
                )

            return

        if name in existing_indexes:
            logger.warning(
                "Index name '%s' already exists with a different "
                "key specification. Existing index preserved.",
                name,
            )
            return

        index_options = {"name": name}

        if unique:
            index_options["unique"] = True

        if sparse:
            index_options["sparse"] = True

        await collection.create_index(
            requested_keys,
            **index_options,
        )

        logger.info(
            "MongoDB index created successfully: %s",
            name,
        )

    except OperationFailure as error:
        if error.code in {85, 86}:
            logger.warning(
                "MongoDB index conflict for '%s'. "
                "Existing index preserved.",
                name,
            )
            return

        logger.exception(
            "MongoDB index creation failed: %s",
            name,
        )
        raise

    except PyMongoError:
        logger.exception(
            "MongoDB index initialization failed: %s",
            name,
        )
        raise


# ---------------------------------------------------------------------
# CREATE DATABASE INDEXES
# ---------------------------------------------------------------------

async def create_database_indexes():
    database = get_database()

    logger.info("Starting MongoDB index initialization")

    await ensure_index(
        database["customers"],
        [("email", 1)],
        name="unique_customer_email",
        unique=True,
    )

    await ensure_index(
        database["customers"],
        [("phone", 1)],
        name="unique_customer_phone",
        unique=True,
        sparse=True,
    )

    await ensure_index(
        database["bookings"],
        [
            ("customer_id", 1),
            ("created_at", -1),
        ],
        name="booking_customer_created",
    )

    await ensure_index(
        database["bookings"],
        [
            ("status", 1),
            ("created_at", -1),
        ],
        name="booking_status_created",
    )

    await ensure_index(
        database["foods"],
        [
            ("category", 1),
            ("is_available", 1),
        ],
        name="food_category_available",
    )

    await ensure_index(
        database["notifications"],
        [
            ("customer_id", 1),
            ("is_read", 1),
            ("created_at", -1),
        ],
        name="notification_customer_read",
    )

    await ensure_index(
        database["notifications"],
        [
            ("recipient_role", 1),
            ("is_read", 1),
            ("created_at", -1),
        ],
        name="notification_role_read",
    )

    await ensure_index(
        database["reviews"],
        [
            ("customer_id", 1),
            ("created_at", -1),
        ],
        name="review_customer_created",
    )

    logger.info("MongoDB index initialization completed")


# ---------------------------------------------------------------------
# CONNECT TO MONGODB
# ---------------------------------------------------------------------

async def connect_to_mongo() -> None:
    client = get_client()

    try:
        await client.admin.command("ping")

        logger.info("MongoDB Atlas connected successfully.")

        await create_database_indexes()

        logger.info(
            "Nivetha Catering database initialization completed."
        )

    except PyMongoError:
        logger.exception("MongoDB connection or operation failed.")
        raise

    except Exception:
        logger.exception("MongoDB initialization failed.")
        raise


# ---------------------------------------------------------------------
# CLOSE MONGODB CONNECTION
# ---------------------------------------------------------------------

async def close_mongo_connection() -> None:
    if db_manager.client is not None:
        db_manager.client.close()
        db_manager.client = None

        logger.info("MongoDB connection pool closed.")
