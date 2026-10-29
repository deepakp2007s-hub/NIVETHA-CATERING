from pymongo import ASCENDING, DESCENDING, MongoClient
from app.core.config import settings
client = MongoClient(settings.MONGODB_URI,serverSelectionTimeoutMS=5000,connectTimeoutMS=10000,retryWrites=True,tz_aware=True,)
customer_db = client[settings.CUSTOMER_DATABASE_NAME]
owner_db = client[settings.OWNER_DATABASE_NAME]
def check_mongodb() -> bool:
    """Check whether MongoDB is reachable."""
    client.admin.command("ping")
    return True
def create_customer_indexes() -> None:
    """Create customer email and phone indexes."""
    customers = customer_db["customers"]
    customers.create_index(
        [("email", ASCENDING)],unique=True,name="unique_customer_email_v2",partialFilterExpression={"email": {"$type": "string"}}, )
    customers.create_index([("phone", ASCENDING)],unique=True,name="unique_customer_phone_v2",partialFilterExpression={"phone": {"$type": "string"}}, )
def create_application_indexes() -> None:
    """Create indexes for bookings, notifications, foods and reviews."""
    customer_db["bookings"].create_index([("customer_id", ASCENDING), ("created_at", DESCENDING)], name="customer_bookings_created_at", )
    customer_db["notifications"].create_index([("recipient_role", ASCENDING), ("created_at", DESCENDING)], name="notifications_role_created_at",)
    customer_db["notifications"].create_index([("customer_id", ASCENDING), ("created_at", DESCENDING)],name="notifications_customer_created_at",)
    customer_db["foods"].create_index([("is_available", ASCENDING), ("created_at", DESCENDING)],name="foods_availability_created_at",)
    customer_db["reviews"].create_index([("customer_id", ASCENDING), ("created_at", DESCENDING)],name="reviews_customer_created_at",)
def close_mongodb() -> None:
    """Close MongoDB connection."""
    client.close()
