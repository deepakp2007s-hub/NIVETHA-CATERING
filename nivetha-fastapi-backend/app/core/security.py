
import os
from pathlib import Path
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
from pwdlib import PasswordHash


# Load .env from the FastAPI backend root directory.
BACKEND_ROOT = Path(__file__).resolve().parents[2]
ENV_FILE = BACKEND_ROOT / ".env"
load_dotenv(dotenv_path=ENV_FILE, override=False)


password_hash = PasswordHash.recommended()

JWT_SECRET = os.getenv("JWT_SECRET", "").strip()
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30")
)


def _get_jwt_secret() -> str:
    """Return a valid JWT secret without exposing its value."""
    secret = os.getenv("JWT_SECRET", "").strip()

    if len(secret) < 32:
        raise RuntimeError(
            "JWT_SECRET must be configured with at least 32 characters "
            "in the backend .env file or environment."
        )

    return secret


def hash_password(password: str) -> str:
    """Hash a password before storing it."""
    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    """Verify a password against its stored hash."""
    return password_hash.verify(password, hashed_password)


def create_access_token(
    subject: str,
    role: str = "customer",
    expires_minutes: int | None = None,
) -> str:
    """Create a signed JWT access token."""
    secret = _get_jwt_secret()

    if expires_minutes is None:
        expires_minutes = ACCESS_TOKEN_EXPIRE_MINUTES

    now = datetime.now(timezone.utc)

    payload = {
        "sub": subject,
        "role": role,
        "iat": now,
        "exp": now + timedelta(minutes=expires_minutes),
    }

    return jwt.encode(
        payload,
        secret,
        algorithm=JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict:
    """Validate and decode a JWT access token."""
    secret = _get_jwt_secret()

    return jwt.decode(
        token,
        secret,
        algorithms=[JWT_ALGORITHM],
        options={"require": ["sub", "exp", "iat"]},
    )
