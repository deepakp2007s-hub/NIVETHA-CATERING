from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.reports import get_customer_id, require_owner_or_admin


def customer_auth(client: TestClient, customer_id: str):
    client.app.dependency_overrides[get_customer_id] = lambda: customer_id


def staff_auth(client: TestClient, role: str = "owner"):
    client.app.dependency_overrides[require_owner_or_admin] = lambda: {
        "sub": role,
        "role": role,
    }


def clear_auth(client: TestClient):
    client.app.dependency_overrides.pop(get_customer_id, None)
    client.app.dependency_overrides.pop(require_owner_or_admin, None)


def test_get_my_booking_report(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reports/my-bookings")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert "report_generated_at" in data
        assert "summary" in data
        assert "bookings" in data

        summary = data["summary"]
        assert "total_bookings" in summary
        assert "pending_bookings" in summary
        assert "confirmed_bookings" in summary
        assert "completed_bookings" in summary
        assert "cancelled_bookings" in summary
        assert "rejected_bookings" in summary
        assert isinstance(data["bookings"], list)
    finally:
        clear_auth(client)


def test_get_my_booking_report_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/reports/my-bookings")

    assert response.status_code == 401


def test_get_owner_booking_report(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.get("/api/reports/owner/summary")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert "summary" in data
        assert "bookings" in data
        assert isinstance(data["bookings"], list)
    finally:
        clear_auth(client)


def test_get_admin_booking_report(client: TestClient):
    staff_auth(client, "admin")

    try:
        response = client.get("/api/reports/admin/summary")

        assert response.status_code == 200
        assert response.json()["success"] is True
    finally:
        clear_auth(client)


def test_get_staff_report_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/reports/owner/summary")

    assert response.status_code == 401


def test_customer_cannot_access_staff_report(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reports/owner/summary")

        assert response.status_code == 403
    finally:
        clear_auth(client)


def test_staff_report_contains_customer_id(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.get("/api/reports/owner/summary")

        assert response.status_code == 200

        for booking in response.json()["bookings"]:
            assert "customer_id" in booking
    finally:
        clear_auth(client)


def test_customer_report_hides_customer_id(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reports/my-bookings")

        assert response.status_code == 200

        for booking in response.json()["bookings"]:
            assert "customer_id" not in booking
    finally:
        clear_auth(client)