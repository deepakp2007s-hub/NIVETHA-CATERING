import re
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient
from pydantic import SecretStr

from app.core.config import settings
from app.main import app

client = TestClient(app)

AUTH_URL = "/api/v1/auth"

SUPPORTED_METHODS = {
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
}


def generate_test_id(parameter_name: str) -> str:
    if parameter_name == "booking_id":
        return f"NIV-TEST{uuid4().hex[:8].upper()}"

    if parameter_name in {
        "customer_id",
        "food_id",
        "notification_id",
        "review_id",
        "id",
    }:
        return uuid4().hex[:24]

    return f"test-{uuid4().hex[:12]}"


def resolve_path(path: str) -> str:
    return re.sub(
        r"\{([^}]+)\}",
        lambda match: generate_test_id(match.group(1)),
        path,
    )


def collect_api_cases():
    cases = []

    for path, methods in app.openapi()["paths"].items():
        for method in methods:
            method = method.upper()

            if method not in SUPPORTED_METHODS:
                continue

            cases.append(
                pytest.param(
                    method,
                    path,
                    id=f"{method}-{path.replace('/', '_')}",
                )
            )

    return cases


API_CASES = collect_api_cases()


@pytest.fixture
def auth_settings(monkeypatch):
    owner_email = "owner@example.com"
    owner_password = "OwnerTestPassword123!"

    admin_email = "admin@example.com"
    admin_password = "AdminTestPassword123!"

    monkeypatch.setattr(
        settings,
        "JWT_SECRET",
        SecretStr("test-only-jwt-secret-key-12345678901234567890"),
    )

    monkeypatch.setattr(settings, "JWT_ALGORITHM", "HS256")
    monkeypatch.setattr(settings, "OWNER_EMAIL", owner_email)
    monkeypatch.setattr(settings, "ADMIN_EMAIL", admin_email)

    monkeypatch.setattr(
        settings,
        "OWNER_PASSWORD",
        SecretStr(owner_password),
    )

    monkeypatch.setattr(
        settings,
        "ADMIN_PASSWORD",
        SecretStr(admin_password),
    )

    return {
        "owner_email": owner_email,
        "owner_password": owner_password,
        "admin_email": admin_email,
        "admin_password": admin_password,
    }


@pytest.fixture
def customer_payload():
    unique = uuid4().hex

    return {
        "name": "Test Customer",
        "email": f"customer-{unique[:8]}@example.com",
        "phone": f"9{str(uuid4().int)[:9]}",
        "password": "CustomerTest123!",
    }


# =====================================================
# BASIC HEALTH TESTS
# =====================================================


def test_root_endpoint():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json().get("success") is True


def test_health_endpoint():
    response = client.get("/api/v1/health")

    assert response.status_code == 200

    data = response.json()

    assert data["success"] is True
    assert data["message"] == "Nivetha Catering API is running"


def test_database_health_endpoint():
    response = client.get("/api/v1/health/database")

    assert response.status_code in {200, 503}

    data = response.json()

    if response.status_code == 200:
        assert data["success"] is True
        assert data["status"] == "healthy"
        assert data["message"] == "MongoDB connected successfully"
    else:
        assert data["detail"] is not None


# =====================================================
# ROUTE REGISTRATION TESTS
# =====================================================


def test_api_routes_are_registered():
    paths = app.openapi()["paths"]

    assert paths

    required_paths = [
        "/api/v1/auth/register",
        "/api/v1/auth/login",
        "/api/v1/auth/owner/login",
        "/api/v1/auth/admin/login",
        "/api/v1/customers/me",
        "/api/v1/customers/",
        "/api/v1/profile/me",
        "/api/v1/foods/",
        "/api/v1/bookings/",
        "/api/v1/bookings/my-bookings",
        "/api/v1/bookings/owner/all",
        "/api/v1/reviews/",
        "/api/v1/reviews/my-reviews",
        "/api/v1/reports/my-bookings",
        "/api/v1/reports/owner/summary",
        "/api/v1/reports/admin/summary",
        "/api/v1/notifications/",
        "/api/v1/notifications/owner",
    ]

    for path in required_paths:
        assert path in paths, f"Missing required route: {path}"


def test_admin_login_route_is_registered():
    assert "/api/v1/auth/admin/login" in app.openapi()["paths"]


def test_admin_report_route_is_registered():
    assert "/api/v1/reports/admin/summary" in app.openapi()["paths"]


# =====================================================
# AUTHENTICATION PROTECTION TESTS
# =====================================================


@pytest.mark.parametrize(
    "path",
    [
        "/api/v1/customers/me",
        "/api/v1/profile/me",
        "/api/v1/bookings/my-bookings",
        "/api/v1/reviews/my-reviews",
        "/api/v1/notifications/",
        "/api/v1/notifications/owner",
        "/api/v1/reports/owner/summary",
        "/api/v1/reports/admin/summary",
    ],
)
def test_protected_routes_require_authentication(path):
    response = client.get(path)

    assert response.status_code == 401, (
        f"{path} should require authentication. "
        f"Received {response.status_code}: {response.text}"
    )


# =====================================================
# CUSTOMER AUTHENTICATION TESTS
# =====================================================


def test_customer_register_success(customer_payload, auth_settings):
    response = client.post(
        f"{AUTH_URL}/register",
        json=customer_payload,
    )

    assert response.status_code == 201, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["customer"]["email"] == customer_payload["email"]
    assert data["customer"]["name"] == customer_payload["name"]
    assert "password" not in data["customer"]
    assert "password_hash" not in data["customer"]


def test_customer_register_duplicate_email(
    customer_payload,
    auth_settings,
):
    first_response = client.post(
        f"{AUTH_URL}/register",
        json=customer_payload,
    )

    assert first_response.status_code == 201, first_response.text

    duplicate_payload = {
        **customer_payload,
        "phone": f"8{str(uuid4().int)[:9]}",
    }

    response = client.post(
        f"{AUTH_URL}/register",
        json=duplicate_payload,
    )

    assert response.status_code == 409


def test_customer_register_duplicate_phone(
    customer_payload,
    auth_settings,
):
    first_response = client.post(
        f"{AUTH_URL}/register",
        json=customer_payload,
    )

    assert first_response.status_code == 201, first_response.text

    duplicate_payload = {
        **customer_payload,
        "email": f"another-{uuid4().hex[:8]}@example.com",
    }

    response = client.post(
        f"{AUTH_URL}/register",
        json=duplicate_payload,
    )

    assert response.status_code == 409


def test_customer_register_invalid_email(auth_settings):
    response = client.post(
        f"{AUTH_URL}/register",
        json={
            "name": "Test Customer",
            "email": "invalid-email",
            "phone": f"9{str(uuid4().int)[:9]}",
            "password": "CustomerTest123!",
        },
    )

    assert response.status_code == 422


def test_customer_login_success(customer_payload, auth_settings):
    register_response = client.post(
        f"{AUTH_URL}/register",
        json=customer_payload,
    )

    assert register_response.status_code == 201, register_response.text

    response = client.post(
        f"{AUTH_URL}/login",
        json={
            "email": customer_payload["email"],
            "password": customer_payload["password"],
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["customer"]["email"] == customer_payload["email"]


def test_customer_login_wrong_password(
    customer_payload,
    auth_settings,
):
    register_response = client.post(
        f"{AUTH_URL}/register",
        json=customer_payload,
    )

    assert register_response.status_code == 201, register_response.text

    response = client.post(
        f"{AUTH_URL}/login",
        json={
            "email": customer_payload["email"],
            "password": "WrongPassword123!",
        },
    )

    assert response.status_code == 401


def test_customer_login_unknown_email(auth_settings):
    response = client.post(
        f"{AUTH_URL}/login",
        json={
            "email": f"unknown-{uuid4().hex[:8]}@example.com",
            "password": "UnknownPassword123!",
        },
    )

    assert response.status_code == 401


# =====================================================
# OWNER AUTHENTICATION TESTS
# =====================================================


def test_owner_login_success(auth_settings):
    response = client.post(
        f"{AUTH_URL}/owner/login",
        json={
            "email": auth_settings["owner_email"],
            "password": auth_settings["owner_password"],
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["owner"]["role"] == "owner"


def test_owner_login_wrong_password(auth_settings):
    response = client.post(
        f"{AUTH_URL}/owner/login",
        json={
            "email": auth_settings["owner_email"],
            "password": "WrongOwnerPassword123!",
        },
    )

    assert response.status_code == 401


def test_owner_login_wrong_email(auth_settings):
    response = client.post(
        f"{AUTH_URL}/owner/login",
        json={
            "email": "wrong-owner@example.com",
            "password": auth_settings["owner_password"],
        },
    )

    assert response.status_code == 401


# =====================================================
# ADMIN AUTHENTICATION TESTS
# =====================================================


def test_admin_login_success(auth_settings):
    response = client.post(
        f"{AUTH_URL}/admin/login",
        json={
            "email": auth_settings["admin_email"],
            "password": auth_settings["admin_password"],
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["admin"]["role"] == "admin"


def test_admin_login_wrong_password(auth_settings):
    response = client.post(
        f"{AUTH_URL}/admin/login",
        json={
            "email": auth_settings["admin_email"],
            "password": "WrongAdminPassword123!",
        },
    )

    assert response.status_code == 401


def test_admin_login_wrong_email(auth_settings):
    response = client.post(
        f"{AUTH_URL}/admin/login",
        json={
            "email": "wrong-admin@example.com",
            "password": auth_settings["admin_password"],
        },
    )

    assert response.status_code == 401


# =====================================================
# UNKNOWN ROUTE
# =====================================================


def test_unknown_endpoint_returns_404():
    response = client.get("/api/v1/this-endpoint-does-not-exist")

    assert response.status_code == 404


# =====================================================
# ALL-ROUTE SMOKE TESTS
# =====================================================


@pytest.mark.parametrize(
    "method,template_path",
    API_CASES,
)
def test_all_registered_routes(method: str, template_path: str):
    path = resolve_path(template_path)

    response = client.request(
        method=method,
        url=path,
        headers={"Accept": "application/json"},
    )

    assert response.status_code < 500, (
        f"{method} {path} returned HTTP {response.status_code}. "
        f"Response: {response.text[:500]}"
    )