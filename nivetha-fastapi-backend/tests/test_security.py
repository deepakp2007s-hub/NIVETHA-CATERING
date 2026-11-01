from datetime import UTC, datetime, timedelta

import jwt
import pytest

from app.core import security


def test_hash_password():
    password = "TestPassword123!"

    hashed = security.hash_password(password)

    assert hashed != password
    assert security.verify_password(password, hashed) is True


def test_verify_password_wrong_password():
    hashed = security.hash_password("TestPassword123!")

    assert security.verify_password("WrongPassword123!", hashed) is False


def test_hash_empty_password():
    with pytest.raises(ValueError):
        security.hash_password("")


def test_verify_empty_password():
    assert security.verify_password("", "hashed-password") is False


def test_verify_invalid_hash():
    assert security.verify_password("TestPassword123!", "") is False


def test_create_customer_access_token(monkeypatch):
    monkeypatch.setattr(
        security.settings,
        "JWT_SECRET",
        security.settings.JWT_SECRET,
    )

    token = security.create_access_token(
        subject="507f1f77bcf86cd799439011",
        role="customer",
    )

    payload = security.decode_access_token(token)

    assert payload["sub"] == "507f1f77bcf86cd799439011"
    assert payload["role"] == "customer"
    assert "exp" in payload
    assert "iat" in payload


@pytest.mark.parametrize("role", ["owner", "admin"])
def test_create_staff_access_token(role):
    token = security.create_access_token(
        subject=role,
        role=role,
    )

    payload = security.decode_access_token(token)

    assert payload["sub"] == role
    assert payload["role"] == role


def test_create_token_invalid_role():
    with pytest.raises(ValueError):
        security.create_access_token(
            subject="test-user",
            role="unknown",
        )


def test_create_token_empty_subject():
    with pytest.raises(ValueError):
        security.create_access_token(
            subject="",
            role="customer",
        )


@pytest.mark.parametrize("expiration", [0, -1, True, "30"])
def test_create_token_invalid_expiration(expiration):
    with pytest.raises(ValueError):
        security.create_access_token(
            subject="test-user",
            role="customer",
            expires_minutes=expiration,
        )


def test_decode_invalid_token():
    with pytest.raises(jwt.InvalidTokenError):
        security.decode_access_token("invalid-token")


def test_decode_empty_token():
    with pytest.raises(jwt.InvalidTokenError):
        security.decode_access_token("")


def test_decode_expired_token(monkeypatch):
    secret = "test-jwt-secret-key-at-least-32-characters"

    monkeypatch.setattr(
        security.settings,
        "JWT_SECRET",
        secret,
    )

    expired_token = jwt.encode(
        {
            "sub": "test-user",
            "role": "customer",
            "iat": datetime.now(UTC) - timedelta(minutes=10),
            "exp": datetime.now(UTC) - timedelta(minutes=5),
        },
        secret,
        algorithm="HS256",
    )

    with pytest.raises(jwt.ExpiredSignatureError):
        security.decode_access_token(expired_token)


def test_decode_invalid_staff_subject():
    secret, _ = security._get_jwt_config()

    token = jwt.encode(
        {
            "sub": "wrong-owner",
            "role": "owner",
            "iat": datetime.now(UTC),
            "exp": datetime.now(UTC) + timedelta(minutes=30),
        },
        secret,
        algorithm="HS256",
    )

    with pytest.raises(jwt.InvalidTokenError):
        security.decode_access_token(token)


def test_decode_invalid_role():
    secret, _ = security._get_jwt_config()

    token = jwt.encode(
        {
            "sub": "test-user",
            "role": "superadmin",
            "iat": datetime.now(UTC),
            "exp": datetime.now(UTC) + timedelta(minutes=30),
        },
        secret,
        algorithm="HS256",
    )

    with pytest.raises(jwt.InvalidTokenError):
        security.decode_access_token(token)


def test_jwt_secret_too_short(monkeypatch):
    monkeypatch.setattr(
        security.settings,
        "JWT_SECRET",
        "short",
    )

    with pytest.raises(RuntimeError):
        security._get_jwt_config()


def test_invalid_jwt_algorithm(monkeypatch):
    monkeypatch.setattr(
        security.settings,
        "JWT_ALGORITHM",
        "HS512",
    )

    with pytest.raises(RuntimeError):
        security._get_jwt_config()


def test_invalid_access_token_expiration_setting(monkeypatch):
    monkeypatch.setattr(
        security.settings,
        "ACCESS_TOKEN_EXPIRE_MINUTES",
        0,
    )

    with pytest.raises(RuntimeError):
        security._get_jwt_config()