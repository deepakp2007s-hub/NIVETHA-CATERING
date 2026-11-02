import logging
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from pwdlib import PasswordHash
from pwdlib.exceptions import PwdlibError

from app.core.config import settings

logger = logging.getLogger(__name__)

password_hash = PasswordHash.recommended()

ALLOWED_ROLES = {"customer", "owner", "admin"}
JWT_ALGORITHM = "HS256"


def _get_jwt_config() -> tuple[str, int]:
    """Read and validate JWT configuration from application settings."""

    secret = settings.jwt_secret_value
    algorithm = settings.JWT_ALGORITHM
    expiration = settings.ACCESS_TOKEN_EXPIRE_MINUTES

    if not secret:
        raise RuntimeError("JWT_SECRET environment variable is missing or empty.")

    if len(secret) < 32:
        if settings.ENVIRONMENT == "production":
            raise RuntimeError("JWT_SECRET must contain at least 32 characters in production.")
        logger.warning("JWT_SECRET is fewer than 32 characters. Consider updating for better security.")

    if algorithm != JWT_ALGORITHM:
        raise RuntimeError("JWT_ALGORITHM must be HS256.")

    if (
        isinstance(expiration, bool)
        or not isinstance(expiration, int)
        or expiration <= 0
    ):
        raise RuntimeError("ACCESS_TOKEN_EXPIRE_MINUTES must be a positive integer.")

    return secret, expiration


def hash_password(password: str) -> str:
    """Hash a raw password before persisting to MongoDB."""

    if not isinstance(password, str) or not password:
        raise ValueError("Password cannot be empty.")

    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    """Verify a plain password against its stored hash."""

    if not isinstance(password, str) or not password:
        return False

    if not isinstance(hashed_password, str) or not hashed_password:
        return False

    try:
        return password_hash.verify(password, hashed_password)
    except (ValueError, TypeError, PwdlibError):
        return False


def needs_rehash(hashed_password: str) -> bool:
    """Check whether stored hash should be upgraded to current parameters."""
    try:
        return password_hash.recommended().verify_and_update(
            password="", hash=hashed_password
        )[1]
    except Exception:
        return False


def create_access_token(
    subject: str,
    role: str = "customer",
    expires_minutes: int | None = None,
) -> str:
    """Create a signed JWT for customer, owner, or admin."""

    if not isinstance(subject, str) or not subject.strip():
        raise ValueError("Token subject cannot be empty.")

    if role not in ALLOWED_ROLES:
        raise ValueError(f"Unsupported token role '{role}'. Must be one of {ALLOWED_ROLES}.")

    secret, default_expiration = _get_jwt_config()

    expiration = default_expiration if expires_minutes is None else expires_minutes

    if (
        isinstance(expiration, bool)
        or not isinstance(expiration, int)
        or expiration <= 0
    ):
        raise ValueError("Token expiration must be a positive integer.")

    now = datetime.now(UTC)

    payload: dict[str, Any] = {
        "sub": subject.strip(),
        "role": role,
        "iat": now,
        "exp": now + timedelta(minutes=expiration),
    }

    return jwt.encode(
        payload,
        secret,
        algorithm=JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict[str, Any]:
    """Validate and decode a JWT access token."""

    if not isinstance(token, str) or not token.strip():
        raise jwt.InvalidTokenError("Token string cannot be empty.")

    secret, _ = _get_jwt_config()

    try:
        payload = jwt.decode(
            token,
            secret,
            algorithms=[JWT_ALGORITHM],
            options={
                "require": ["sub", "exp", "iat", "role"],
                "verify_iat": True,
                "verify_exp": True,
            },
        )
    except jwt.PyJWTError as exc:
        raise jwt.InvalidTokenError("Failed to decode token.") from exc

    if not isinstance(payload, dict):
        raise jwt.InvalidTokenError("Invalid token payload shape.")

    subject = payload.get("sub")
    role = payload.get("role")

    if not isinstance(subject, str) or not subject.strip():
        raise jwt.InvalidTokenError("Invalid token subject.")

    if role not in ALLOWED_ROLES:
        raise jwt.InvalidTokenError("Invalid token role.")

    if role in {"owner", "admin"} and subject != role:
        raise jwt.InvalidTokenError("Invalid staff token subject binding.")

    return payload