
from functools import lru_cache
from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


BACKEND_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    APP_NAME: str = "Nivetha Catering API"
    APP_VERSION: str = "1.1.0"
    ENVIRONMENT: str = "development"

    MONGODB_URI: str = Field(min_length=1)
    CUSTOMER_DATABASE_NAME: str = "nivetha_customer"
    OWNER_DATABASE_NAME: str = "nivetha_owner"

    JWT_SECRET: str = Field(min_length=32)
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30, gt=0)

    CORS_ORIGINS: str = (
        "http://localhost:3000,"
        "http://localhost:5173,"
        "http://localhost:8080,"
        "http://127.0.0.1:3000,"
        "http://127.0.0.1:5173,"
        "https://nivetha-catering.vercel.app,"
        "https://nivetha-catering-kjh1.vercel.app"
    )

    model_config = SettingsConfigDict(
        env_file=str(BACKEND_ROOT / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True,
    )

    @field_validator(
        "MONGODB_URI",
        "CUSTOMER_DATABASE_NAME",
        "OWNER_DATABASE_NAME",
        "JWT_SECRET",
        "JWT_ALGORITHM",
        "ENVIRONMENT",
        "CORS_ORIGINS",
    )
    @classmethod
    def validate_strings(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError(
                "This configuration value cannot be empty."
            )

        return value

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_jwt_algorithm(cls, value: str) -> str:
        if value != "HS256":
            raise ValueError(
                "This application currently supports HS256 only."
            )

        return value

    @field_validator("ACCESS_TOKEN_EXPIRE_MINUTES")
    @classmethod
    def validate_token_expiry(cls, value: int) -> int:
        if value <= 0:
            raise ValueError(
                "ACCESS_TOKEN_EXPIRE_MINUTES must be greater than zero."
            )

        return value

    @property
    def cors_origins_list(self) -> list[str]:
        return list(
            dict.fromkeys(
                origin.strip().rstrip("/")
                for origin in self.CORS_ORIGINS.split(",")
                if origin.strip()
            )
        )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
