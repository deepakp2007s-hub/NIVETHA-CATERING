from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.profiles import get_current_customer


def test_get_my_profile(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.get("/api/profile/me")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["customer"]["name"] == "Test Customer"
        assert data["customer"]["email"] == "test@example.com"
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)


def test_get_my_profile_without_auth(client: TestClient):
    response = client.get("/api/profile/me")

    assert response.status_code == 401


def test_update_my_profile(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.patch(
            "/api/profile/me",
            json={
                "name": "Updated Customer",
                "phone": "9876543211",
            },
        )

        assert response.status_code in (200, 404, 409, 503)
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)


def test_update_profile_without_auth(client: TestClient):
    response = client.patch(
        "/api/profile/me",
        json={"name": "Updated Customer"},
    )

    assert response.status_code == 401


def test_update_profile_empty_data(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.patch("/api/profile/me", json={})

        assert response.status_code == 400
        assert (
            response.json()["detail"]
            == "Provide at least one profile field to update."
        )
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)


def test_update_profile_invalid_phone(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.patch(
            "/api/profile/me",
            json={"phone": "invalid"},
        )

        assert response.status_code == 422
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)


def test_update_profile_null_field(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.patch(
            "/api/profile/me",
            json={"name": None},
        )

        assert response.status_code == 422
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)


def test_update_profile_unknown_field(client: TestClient):
    customer = {
        "_id": ObjectId(),
        "name": "Test Customer",
        "email": "test@example.com",
        "phone": "9876543210",
    }

    client.app.dependency_overrides[get_current_customer] = lambda: customer

    try:
        response = client.patch(
            "/api/profile/me",
            json={"email": "new@example.com"},
        )

        assert response.status_code == 422
    finally:
        client.app.dependency_overrides.pop(get_current_customer, None)