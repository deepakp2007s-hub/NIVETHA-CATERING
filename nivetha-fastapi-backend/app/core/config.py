import logging
from functools import lru_cache
from pathlib import Path

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    APP_NAME: str = "Nivetha Catering API"
    APP_VERSION: str = "1.1.0"
    ENVIRONMENT: str = "development"

    MONGODB_URI: SecretStr = Field(default=SecretStr(""))

    CUSTOMER_DATABASE_NAME: str = "nivetha_customer"
    OWNER_DATABASE_NAME: str = "nivetha_owner"

    JWT_SECRET: SecretStr = Field(default=SecretStr(""))
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=43200, gt=0)  # 30 days for mobile app session longevity

    ADMIN_EMAIL: str = ""
    ADMIN_PASSWORD: SecretStr = Field(default=SecretStr(""))

    OWNER_EMAIL: str = ""
    OWNER_PASSWORD: SecretStr = Field(default=SecretStr(""))

    ADMIN_PASSWORD_HASH: SecretStr = Field(default=SecretStr(""))
    OWNER_PASSWORD_HASH: SecretStr = Field(default=SecretStr(""))

    LOGIN_RATE_LIMIT_WINDOW_SECONDS: int = Field(default=900, gt=0)
    LOGIN_RATE_LIMIT_MAX_ATTEMPTS: int = Field(default=5, gt=0)

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
        env_file=BASE_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True,
    )

    @field_validator(
        "APP_NAME",
        "APP_VERSION",
        "ENVIRONMENT",
        "CUSTOMER_DATABASE_NAME",
        "OWNER_DATABASE_NAME",
        "JWT_ALGORITHM",
        "CORS_ORIGINS",
    )
    @classmethod
    def validate_strings(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("This configuration value cannot be empty.")
        return value

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_jwt_algorithm(cls, value: str) -> str:
        if value != "HS256":
            raise ValueError("This application currently supports HS256 only.")
        return value

    @field_validator("ACCESS_TOKEN_EXPIRE_MINUTES")
    @classmethod
    def validate_token_expiry(cls, value: int) -> int:
        if value <= 0:
            raise ValueError("ACCESS_TOKEN_EXPIRE_MINUTES must be greater than zero.")
        return value

    @field_validator(
        "LOGIN_RATE_LIMIT_WINDOW_SECONDS",
        "LOGIN_RATE_LIMIT_MAX_ATTEMPTS",
    )
    @classmethod
    def validate_rate_limit(cls, value: int) -> int:
        if value <= 0:
            raise ValueError("Login rate-limit settings must be greater than zero.")
        return value

    @property
    def mongodb_uri_value(self) -> str:
        val = self.MONGODB_URI.get_secret_value().strip()
        if not val:
            logger.warning("MONGODB_URI is not set in environment or .env file.")
        return val

    @property
    def jwt_secret_value(self) -> str:
        val = self.JWT_SECRET.get_secret_value().strip()
        if not val:
            logger.warning("JWT_SECRET is not set in environment or .env file.")
        elif len(val) < 32 and self.ENVIRONMENT == "production":
            logger.warning("JWT_SECRET is under 32 characters; consider using a stronger secret key.")
        return val

    @property
    def admin_password_value(self) -> str:
        return self.ADMIN_PASSWORD.get_secret_value()

    @property
    def owner_password_value(self) -> str:
        return self.OWNER_PASSWORD.get_secret_value()

    @property
    def admin_password_hash_value(self) -> str:
        return self.ADMIN_PASSWORD_HASH.get_secret_value().strip()

    @property
    def owner_password_hash_value(self) -> str:
        return self.OWNER_PASSWORD_HASH.get_secret_value().strip()

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