
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path

import jwt
from dotenv import load_dotenv
from pwdlib import PasswordHash


BACKEND_ROOT = Path(__file__).resolve().parents[2]
ENV_FILE = BACKEND_ROOT / ".env"

load_dotenv(dotenv_path=ENV_FILE, override=False)

password_hash = PasswordHash.recommended()

ALLOWED_ROLES = {"customer", "owner"}
JWT_ALGORITHM = "HS256"


def _get_jwt_config() -> tuple[str, int]:
    """Load and validate JWT settings from environment variables."""
    secret = os.getenv("JWT_SECRET", "").strip()
    algorithm = os.getenv("JWT_ALGORITHM", JWT_ALGORITHM).strip()
    expiration_raw = os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30").strip()

    if len(secret) < 32:
        raise RuntimeError(
            "JWT_SECRET must contain at least 32 characters."
        )

    if algorithm != JWT_ALGORITHM:
        raise RuntimeError(
            "JWT_ALGORITHM must be HS256."
        )

    try:
        expiration = int(expiration_raw)
    except ValueError as exc:
        raise RuntimeError(
            "ACCESS_TOKEN_EXPIRE_MINUTES must be a positive integer."
        ) from exc

    if expiration <= 0:
        raise RuntimeError(
            "ACCESS_TOKEN_EXPIRE_MINUTES must be greater than zero."
        )

    return secret, expiration


def hash_password(password: str) -> str:
    """Hash a password before storing it in MongoDB."""
    if not isinstance(password, str) or not password:
        raise ValueError("Password cannot be empty.")

    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    """Verify a password against its stored hash."""
    if not isinstance(password, str) or not password:
        return False

    if not isinstance(hashed_password, str) or not hashed_password:
        return False

    try:
        return password_hash.verify(password, hashed_password)
    except (ValueError, TypeError):
        return False


def create_access_token(
    subject: str,
    role: str = "customer",
    expires_minutes: int | None = None,
) -> str:
    """Create a signed JWT for an authenticated application user."""
    if not isinstance(subject, str) or not subject.strip():
        raise ValueError("Token subject cannot be empty.")

    if role not in ALLOWED_ROLES:
        raise ValueError("Unsupported token role.")

    secret, default_expiration = _get_jwt_config()

    expiration = (
        default_expiration
        if expires_minutes is None
        else expires_minutes
    )

    if (
        isinstance(expiration, bool)
        or not isinstance(expiration, int)
        or expiration <= 0
    ):
        raise ValueError("Token expiration must be a positive integer.")

    now = datetime.now(timezone.utc)

    payload = {
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


def decode_access_token(token: str) -> dict:
    """Validate and decode a JWT access token."""
    if not isinstance(token, str) or not token.strip():
        raise jwt.InvalidTokenError("Token is empty.")

    secret, _ = _get_jwt_config()

    payload = jwt.decode(
        token,
        secret,
        algorithms=[JWT_ALGORITHM],
        options={"require": ["sub", "exp", "iat"]},
    )

    if not isinstance(payload, dict):
        raise jwt.InvalidTokenError("Invalid token payload.")

    subject = payload.get("sub")
    role = payload.get("role")

    if not isinstance(subject, str) or not subject.strip():
        raise jwt.InvalidTokenError("Invalid token subject.")

    if role not in ALLOWED_ROLES:
        raise jwt.InvalidTokenError("Invalid token role.")

    return payload
