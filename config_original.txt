from functools import lru_cache
from pathlib import Path

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

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
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30, gt=0)

    ADMIN_EMAIL: str = ""
    ADMIN_PASSWORD: SecretStr = Field(default=SecretStr(""))

    OWNER_EMAIL: str = ""
    OWNER_PASSWORD: SecretStr = Field(default=SecretStr(""))

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

    @property
    def mongodb_uri_value(self) -> str:
        return self.MONGODB_URI.get_secret_value().strip()

    @property
    def jwt_secret_value(self) -> str:
        return self.JWT_SECRET.get_secret_value().strip()

    @property
    def admin_password_value(self) -> str:
        return self.ADMIN_PASSWORD.get_secret_value()

    @property
    def owner_password_value(self) -> str:
        return self.OWNER_PASSWORD.get_secret_value()

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