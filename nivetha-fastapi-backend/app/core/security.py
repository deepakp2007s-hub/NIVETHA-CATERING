
import logging
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

import bcrypt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from app.core.config import settings

logger = logging.getLogger(__name__)

bearer_scheme = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    if not password or not password.strip():
        raise ValueError("Password cannot be empty.")

    password_bytes = password.encode("utf-8")

    if len(password_bytes) > 72:
        raise ValueError("Password cannot exceed 72 UTF-8 bytes.")

    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password_bytes, salt)

    return hashed.decode("utf-8")


def verify_password(
    plain_password: str,
    hashed_password: str,
) -> bool:
    try:
        if not plain_password or not hashed_password:
            return False

        password_bytes = plain_password.encode("utf-8")

        if len(password_bytes) > 72:
            return False

        return bcrypt.checkpw(
            password_bytes,
            hashed_password.encode("utf-8"),
        )

    except (ValueError, TypeError) as exc:
        logger.warning("Password verification failed: %s", exc)
        return False


def create_access_token(
    data: Optional[dict[str, Any]] = None,
    subject: Optional[str] = None,
    expires_delta: Optional[timedelta] = None,
) -> str:
    payload = data.copy() if data else {}

    if subject:
        payload["sub"] = str(subject)

    now = datetime.now(timezone.utc)

    expire = (
        now + expires_delta
        if expires_delta
        else now + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    )

    payload.update({
        "iat": now,
        "exp": expire,
    })

    return jwt.encode(
        payload,
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict[str, Any]:
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM],
            options={
                "require_exp": True,
                "require_sub": True,
            },
        )

        if not isinstance(payload, dict):
            raise ValueError("Invalid token payload.")

        return payload

    except (JWTError, ValueError, TypeError) as exc:
        logger.warning("JWT validation failed: %s", exc)
        raise ValueError("Invalid or expired token.") from exc


def get_current_user_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(
        bearer_scheme
    ),
) -> str:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)

        user_id = payload.get("sub")

        if not user_id:
            raise ValueError("Token subject is missing.")

        return str(user_id)

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
