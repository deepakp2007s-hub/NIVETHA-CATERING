
import logging
from functools import lru_cache
from typing import List
from urllib.parse import urlparse

from pydantic import (
    Field,
    field_validator,
    model_validator,
)
from pydantic_settings import BaseSettings, SettingsConfigDict


logger = logging.getLogger("nivetha_catering.config")


class Settings(BaseSettings):

    # ---------------------------------------------------------
    # APPLICATION
    # ---------------------------------------------------------

    APP_NAME: str = "Nivetha Catering API"
    APP_ENV: str = "development"
    API_V1_PREFIX: str = "/api/v1"

    # ---------------------------------------------------------
    # JWT SECURITY
    # ---------------------------------------------------------

    JWT_SECRET: str = Field(min_length=32)
    JWT_ALGORITHM: str = "HS256"

    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(
        default=30,
        ge=5,
        le=1440,
    )

    # ---------------------------------------------------------
    # MONGODB
    # ---------------------------------------------------------

    MONGODB_URI: str = Field(min_length=1)

    CUSTOMER_DATABASE_NAME: str = "nivetha_customer"
    OWNER_DATABASE_NAME: str = "nivetha_customer"

    # ---------------------------------------------------------
    # FRONTEND URLS
    # ---------------------------------------------------------

    OWNER_URL: str = ""
    CUSTOMER_URL: str = ""

    CORS_ORIGINS: str = ""

    # ---------------------------------------------------------
    # ADMIN CREDENTIALS
    # ---------------------------------------------------------

    ADMIN_EMAIL: str
    ADMIN_PASSWORD: str = Field(min_length=8)

    # ---------------------------------------------------------
    # OWNER CREDENTIALS
    # ---------------------------------------------------------

    OWNER_EMAIL: str
    OWNER_PASSWORD: str = Field(min_length=8)

    # ---------------------------------------------------------
    # PYDANTIC SETTINGS
    # ---------------------------------------------------------

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
        validate_default=True,
    )

    # ---------------------------------------------------------
    # APPLICATION VALIDATION
    # ---------------------------------------------------------

    @field_validator("APP_ENV")
    @classmethod
    def validate_environment(cls, value: str) -> str:
        value = value.strip().lower()

        if value not in {
            "development",
            "testing",
            "production",
        }:
            raise ValueError("Invalid APP_ENV.")

        return value

    @field_validator("API_V1_PREFIX")
    @classmethod
    def validate_api_prefix(cls, value: str) -> str:
        value = value.strip().rstrip("/")

        if not value.startswith("/"):
            raise ValueError("API_V1_PREFIX must start with '/'.")

        if value == "":
            raise ValueError("API_V1_PREFIX cannot be empty.")

        return value

    # ---------------------------------------------------------
    # MONGODB VALIDATION
    # ---------------------------------------------------------

    @field_validator("MONGODB_URI")
    @classmethod
    def validate_mongodb_uri(cls, value: str) -> str:
        value = value.strip()

        if not value.startswith(
            ("mongodb://", "mongodb+srv://")
        ):
            raise ValueError("Invalid MongoDB URI.")

        return value

    @field_validator(
        "CUSTOMER_DATABASE_NAME",
        "OWNER_DATABASE_NAME",
    )
    @classmethod
    def validate_database_name(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError("Database name cannot be empty.")

        return value

    # ---------------------------------------------------------
    # JWT VALIDATION
    # ---------------------------------------------------------

    @field_validator("JWT_SECRET")
    @classmethod
    def validate_jwt_secret(cls, value: str) -> str:
        value = value.strip()

        if len(value) < 32:
            raise ValueError(
                "JWT_SECRET must contain at least 32 characters."
            )

        return value

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_jwt_algorithm(cls, value: str) -> str:
        value = value.strip().upper()

        if value != "HS256":
            raise ValueError(
                "Only HS256 is supported by this application."
            )

        return value

    # ---------------------------------------------------------
    # EMAIL VALIDATION
    # ---------------------------------------------------------

    @field_validator("OWNER_EMAIL", "ADMIN_EMAIL")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        value = value.strip().lower()

        if "@" not in value:
            raise ValueError("Invalid email address.")

        return value

    # ---------------------------------------------------------
    # PASSWORD VALIDATION
    # ---------------------------------------------------------

    @field_validator("ADMIN_PASSWORD", "OWNER_PASSWORD")
    @classmethod
    def validate_password(cls, value: str) -> str:
        value = value.strip()

        if len(value) < 8:
            raise ValueError(
                "Account password must contain at least 8 characters."
            )

        return value

    # ---------------------------------------------------------
    # FRONTEND URL VALIDATION
    # ---------------------------------------------------------

    @field_validator("OWNER_URL", "CUSTOMER_URL")
    @classmethod
    def validate_frontend_url(cls, value: str) -> str:
        value = value.strip().rstrip("/")

        if not value:
            return ""

        parsed = urlparse(value)

        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError("Invalid frontend URL.")

        return value

    # ---------------------------------------------------------
    # CROSS-FIELD VALIDATION
    # ---------------------------------------------------------

    @model_validator(mode="after")
    def validate_production_settings(self):
        if self.APP_ENV == "production":
            if self.JWT_SECRET.lower() in {
                "secret",
                "changeme",
                "your-secret-key",
            }:
                raise ValueError(
                    "Change the default JWT secret before production."
                )

            if self.OWNER_URL.startswith("http://"):
                raise ValueError(
                    "OWNER_URL must use HTTPS in production."
                )

            if self.CUSTOMER_URL.startswith("http://"):
                raise ValueError(
                    "CUSTOMER_URL must use HTTPS in production."
                )

        return self

    # ---------------------------------------------------------
    # BACKWARD COMPATIBILITY
    # ---------------------------------------------------------

    @property
    def SECRET_KEY(self) -> str:
        return self.JWT_SECRET

    @property
    def ALGORITHM(self) -> str:
        return self.JWT_ALGORITHM

    # ---------------------------------------------------------
    # CORS ORIGIN LIST
    # ---------------------------------------------------------

    @property
    def cors_origins_list(self) -> List[str]:

        origins = []

        configured_origins = self.CORS_ORIGINS.split(",")

        for item in configured_origins:
            origin = item.strip().rstrip("/")

            if not origin:
                continue

            parsed = urlparse(origin)

            if (
                parsed.scheme not in {"http", "https"}
                or not parsed.netloc
                or parsed.path
                or parsed.query
                or parsed.fragment
            ):
                logger.warning(
                    "Ignoring invalid CORS origin configuration."
                )
                continue

            origins.append(origin)

        if self.OWNER_URL:
            origins.append(self.OWNER_URL)

        if self.CUSTOMER_URL:
            origins.append(self.CUSTOMER_URL)

        if self.APP_ENV in {"development", "testing"}:
            origins.extend([
                "http://localhost:3000",
                "http://localhost:5173",
            ])

        return list(dict.fromkeys(origins))


# -------------------------------------------------------------
# SETTINGS INSTANCE
# -------------------------------------------------------------

@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
