
import os
from functools import lru_cache

from dotenv import load_dotenv
from pydantic_settings import BaseSettings, SettingsConfigDict


# Load environment variables from the project root .env file.
load_dotenv()


class Settings(BaseSettings):
    APP_NAME: str = "Nivetha Catering API"
    APP_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"

    MONGODB_URI: str
    CUSTOMER_DATABASE_NAME: str = "nivetha_customer"
    OWNER_DATABASE_NAME: str = "nivetha_owner"

    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    CORS_ORIGINS: str = (
        "http://localhost:3000,"
        "http://localhost:5173,"
        "http://localhost:8080,"
        "https://nivetha-catering.vercel.app,"
        "https://nivetha-catering-kjh1.vercel.app"
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True,
    )

    @property
    def cors_origins_list(self) -> list[str]:
        return [
            origin.strip().rstrip("/")
            for origin in self.CORS_ORIGINS.split(",")
            if origin.strip()
        ]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
