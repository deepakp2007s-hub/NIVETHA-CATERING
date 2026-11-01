"""
Nivetha Catering Service - FastAPI Automated API Tests

Covers:
- Root and health endpoints
- Required API route registration
- Customer and staff authentication checks
- Customer registration and login
- Duplicate email and phone validation
- Owner and admin authentication
- All registered API paths and HTTP methods
- Automatic test ID generation

These tests use the in-memory MongoDB mock from conftest.py.
They do not connect to the real MongoDB database.
"""

import re
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient
from pydantic import SecretStr

from app.core.config import settings
from app.main import app

client = TestClient(app)

AUTH_URL = "/api/v1/auth"


# =====================================================
# AUTOMATIC TEST ID GENERATION
# =====================================================


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


# =====================================================
# API ROUTE DISCOVERY
# =====================================================

SUPPORTED_METHODS = {
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
}


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


# =====================================================
# TEST CONFIGURATION
# =====================================================


@pytest.fixture
def auth_settings(monkeypatch):
    monkeypatch.setattr(
        settings,
        "JWT_SECRET",
        SecretStr("test-only-jwt-secret-key-12345678901234567890"),
    )

    monkeypatch.setattr(
        settings,
        "OWNER_EMAIL",
        "owner@example.com",
    )

    monkeypatch.setattr(
        settings,
        "OWNER_PASSWORD",
        SecretStr("OwnerTestPassword123!"),
    )

    monkeypatch.setattr(
        settings,
        "ADMIN_EMAIL",
        "admin@example.com",
    )

    monkeypatch.setattr(
        settings,
        "ADMIN_PASSWORD",
        SecretStr("AdminTestPassword123!"),
    )

    return settings


@pytest.fixture
def customer_payload():
    """Generate unique and valid customer registration data."""

    unique = str(uuid4().int)

    return {
        "name": "Test Customer",
        "email": f"customer-{unique[:8]}@example.com",
        "phone": f"9{unique[:9]}",
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

    assert data.get("success") is True
    assert data.get("message") == "Nivetha Catering API is running"


def test_database_health_endpoint():
    response = client.get("/api/v1/health/database")

    assert response.status_code in {200, 503}

    data = response.json()

    if response.status_code == 200:
        assert data.get("success") is True
        assert data.get("message") == "MongoDB connected"
    else:
        assert data.get("detail") is not None


# =====================================================
# ROUTE REGISTRATION TESTS
# =====================================================


def test_api_routes_are_registered():
    paths = app.openapi()["paths"]

    assert paths, "No API paths are registered"

    required_paths = [
        "/api/v1/auth/register",
        "/api/v1/auth/login",
        "/api/v1/auth/owner/login",
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


def test_customer_profile_requires_login():
    response = client.get("/api/v1/customers/me")
    assert response.status_code == 401


def test_owner_report_requires_login():
    response = client.get("/api/v1/reports/owner/summary")
    assert response.status_code == 401


def test_admin_report_requires_login():
    response = client.get("/api/v1/reports/admin/summary")
    assert response.status_code == 401


def test_customer_reviews_require_login():
    response = client.get("/api/v1/reviews/my-reviews")
    assert response.status_code == 401


def test_customer_notifications_require_login():
    response = client.get("/api/v1/notifications/")
    assert response.status_code == 401


def test_staff_notifications_require_login():
    response = client.get("/api/v1/notifications/owner")
    assert response.status_code == 401


# =====================================================
# CUSTOMER AUTHENTICATION FUNCTIONAL TESTS
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

    assert response.status_code == 409, response.text


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

    assert response.status_code == 409, response.text


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
            "email": "owner@example.com",
            "password": "OwnerTestPassword123!",
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["owner"]["role"] == "owner"


def test_owner_login_invalid_password(auth_settings):
    response = client.post(
        f"{AUTH_URL}/owner/login",
        json={
            "email": "owner@example.com",
            "password": "WrongOwnerPassword123!",
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
            "email": "admin@example.com",
            "password": "AdminTestPassword123!",
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["success"] is True
    assert data["access_token"]
    assert data["token_type"] == "bearer"
    assert data["admin"]["role"] == "admin"


def test_admin_login_invalid_password(auth_settings):
    response = client.post(
        f"{AUTH_URL}/admin/login",
        json={
            "email": "admin@example.com",
            "password": "WrongAdminPassword123!",
        },
    )

    assert response.status_code == 401


# =====================================================
# UNKNOWN ROUTE TEST
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
