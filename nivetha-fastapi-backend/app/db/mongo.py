
import os
from dotenv import load_dotenv
from pymongo import MongoClient, ASCENDING
from pymongo.errors import PyMongoError
load_dotenv()
MONGODB_URI = os.getenv("MONGODB_URI")
if not MONGODB_URI:
    raise RuntimeError(
        "MONGODB_URI is missing. Please configure it in the .env file."
    )
client = MongoClient(
    MONGODB_URI,
    serverSelectionTimeoutMS=5000,
    connectTimeoutMS=10000,
    retryWrites=True,
)
customer_db = client[
    os.getenv("CUSTOMER_DATABASE_NAME", "nivetha_customer")
]
owner_db = client[
    os.getenv("OWNER_DATABASE_NAME", "nivetha_owner")
]
def check_mongodb() -> bool:
    """Check whether the MongoDB server is reachable."""
    client.admin.command("ping")
    return True
def create_customer_indexes() -> None:
    """Create unique indexes so duplicate customer emailsand phone numbers cannot be registered."""
    customers = customer_db["customers"]
    customers.create_index(
        [("email", ASCENDING)],
        unique=True,
        name="unique_customer_email",
    )
    customers.create_index(
        [("phone", ASCENDING)],
        unique=True,
        name="unique_customer_phone",
    )
def close_mongodb() -> None:
    """Close the MongoDB client connection."""
    client.close()
