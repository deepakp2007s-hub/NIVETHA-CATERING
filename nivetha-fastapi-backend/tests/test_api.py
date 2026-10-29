
"""
Nivetha Catering Service - FastAPI Automated API Tests

Covers:
- Health endpoints
- Required API route registration
- Authentication checks
- All registered API paths and HTTP methods
- Automatic test ID generation

Note:
These are smoke tests. They do not replace complete business-logic
tests for registration, bookings, food CRUD, reports, or notifications.
"""

import re
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


# --------------------------------------------------
# AUTOMATIC TEST ID GENERATION
# --------------------------------------------------

def generate_test_id(parameter_name: str) -> str:
    """Generate a fresh test identifier without hardcoded database IDs."""

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
    """Replace OpenAPI path parameters with generated test IDs."""

    return re.sub(
        r"\{([^}]+)\}",
        lambda match: generate_test_id(match.group(1)),
        path,
    )


# --------------------------------------------------
# API ROUTE DISCOVERY
# --------------------------------------------------

SUPPORTED_METHODS = {
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
}


def collect_api_cases():
    """Discover all API paths and supported HTTP methods."""

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


# --------------------------------------------------
# BASIC HEALTH TESTS
# --------------------------------------------------

def test_root_endpoint():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json().get("success") is True


def test_health_endpoint():
    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json().get("success") is True


def test_database_health_endpoint():
    response = client.get("/api/v1/health/database")

    # Database health can fail if MongoDB is unavailable.
    assert response.status_code in {200, 503}

    if response.status_code == 200:
        assert response.json().get("success") is True


# --------------------------------------------------
# ROUTE REGISTRATION TESTS
# --------------------------------------------------

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
        "/api/v1/reports/my-bookings",
        "/api/v1/notifications/",
        "/api/v1/notifications/owner",
    ]

    for path in required_paths:
        assert path in paths, f"Missing required route: {path}"


# --------------------------------------------------
# AUTHENTICATION TESTS
# --------------------------------------------------

def test_customer_profile_requires_login():
    response = client.get("/api/v1/customers/me")

    assert response.status_code == 401


def test_owner_report_requires_login():
    response = client.get("/api/v1/reports/owner/summary")

    assert response.status_code == 401


def test_unknown_endpoint_returns_404():
    response = client.get(
        "/api/v1/this-endpoint-does-not-exist"
    )

    assert response.status_code == 404


# --------------------------------------------------
# ALL-ROUTE SMOKE TESTS
# --------------------------------------------------

@pytest.mark.parametrize(
    "method,template_path",
    collect_api_cases(),
)
def test_all_registered_routes(
    method: str,
    template_path: str,
):
    """
    Smoke-test every documented route without credentials.

    Authentication, validation, and missing-resource responses
    are allowed. Unexpected server errors fail the test.

    A new ID is generated for every parameterized path execution.
    """

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
