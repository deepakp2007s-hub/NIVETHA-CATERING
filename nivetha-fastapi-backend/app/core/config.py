
from functools import lru_cache
from typing import List

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "Nivetha Catering API"
    APP_ENV: str = "development"
    API_V1_PREFIX: str = "/api/v1"

    JWT_SECRET: str = Field(min_length=32)
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30, ge=5)

    MONGODB_URI: str = Field(min_length=1)
    CUSTOMER_DATABASE_NAME: str = "nivetha_customer"
    OWNER_DATABASE_NAME: str = "nivetha_customer"

    OWNER_URL: str = ""
    CUSTOMER_URL: str = ""

    ADMIN_EMAIL: str
    ADMIN_PASSWORD: str = Field(min_length=8)

    OWNER_EMAIL: str
    OWNER_PASSWORD: str = Field(min_length=8)

    CORS_ORIGINS: str = ""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    @field_validator("APP_ENV")
    @classmethod
    def validate_environment(cls, value: str) -> str:
        value = value.strip().lower()

        if value not in {"development", "testing", "production"}:
            raise ValueError("Invalid APP_ENV.")

        return value

    @field_validator("MONGODB_URI")
    @classmethod
    def validate_mongodb_uri(cls, value: str) -> str:
        value = value.strip()

        if not value.startswith(("mongodb://", "mongodb+srv://")):
            raise ValueError("Invalid MongoDB URI.")

        return value

    @field_validator("OWNER_EMAIL", "ADMIN_EMAIL")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        return value.strip().lower()

    @property
    def SECRET_KEY(self) -> str:
        return self.JWT_SECRET

    @property
    def ALGORITHM(self) -> str:
        return self.JWT_ALGORITHM

    @property
    def cors_origins_list(self) -> List[str]:
        origins = [
            item.strip().rstrip("/")
            for item in self.CORS_ORIGINS.split(",")
            if item.strip()
        ]

        if self.OWNER_URL:
            origins.append(self.OWNER_URL.rstrip("/"))

        if self.CUSTOMER_URL:
            origins.append(self.CUSTOMER_URL.rstrip("/"))

        if self.APP_ENV == "development":
            origins.extend([
                "http://localhost:3000",
                "http://localhost:5173",
            ])

        return list(dict.fromkeys(origins))


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
