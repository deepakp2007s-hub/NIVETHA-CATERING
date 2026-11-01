from bson import ObjectId
from fastapi.testclient import TestClient


def test_customer_view_own_details(client: TestClient):
    response = client.get("/customers/me")

    assert response.status_code in (200, 401, 403)

    if response.status_code == 200:
        data = response.json()
        assert data["success"] is True
        assert "customer" in data


def test_customer_view_all(client: TestClient):
    response = client.get("/customers/")

    assert response.status_code in (200, 401, 403)

    if response.status_code == 200:
        data = response.json()
        assert data["success"] is True
        assert "count" in data
        assert "customers" in data
        assert isinstance(data["customers"], list)


def test_customer_view_by_id(client: TestClient):
    customer_id = str(ObjectId())
    response = client.get(f"/customers/{customer_id}")

    assert response.status_code in (200, 401, 403, 404)

    if response.status_code == 200:
        data = response.json()
        assert data["success"] is True
        assert "customer" in data


def test_customer_view_invalid_id(client: TestClient):
    response = client.get("/customers/invalid-id")

    assert response.status_code in (400, 401, 403)

    if response.status_code == 400:
        assert response.json()["detail"] == "Invalid customer ID."