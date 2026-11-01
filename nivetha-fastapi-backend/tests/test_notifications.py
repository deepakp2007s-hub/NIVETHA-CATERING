from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.notifications import (
    get_customer_id,
    require_owner_or_admin,
)


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


def test_get_customer_notifications(client: TestClient):
    customer_id = str(ObjectId())
    customer_auth(client, customer_id)

    try:
        response = client.get("/api/notifications/")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["recipient_type"] == "customer"
        assert isinstance(data["notifications"], list)
        assert "unread_count" in data
    finally:
        clear_auth(client)


def test_get_customer_notifications_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/notifications/")

    assert response.status_code == 401


def test_mark_all_customer_notifications_read(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.patch("/api/notifications/read-all")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert "updated_count" in data
    finally:
        clear_auth(client)


def test_mark_single_customer_notification_read(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.patch(
            f"/api/notifications/{ObjectId()}/read"
        )

        assert response.status_code in (200, 404)
    finally:
        clear_auth(client)


def test_mark_customer_notification_invalid_id(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.patch(
            "/api/notifications/invalid-id/read"
        )

        assert response.status_code == 400
    finally:
        clear_auth(client)


def test_get_owner_notifications(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.get("/api/notifications/owner")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["recipient_type"] == "owner"
        assert isinstance(data["notifications"], list)
    finally:
        clear_auth(client)


def test_get_admin_notifications(client: TestClient):
    staff_auth(client, "admin")

    try:
        response = client.get("/api/notifications/admin")

        assert response.status_code == 200
        assert response.json()["success"] is True
    finally:
        clear_auth(client)


def test_get_owner_notifications_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/notifications/owner")

    assert response.status_code == 401


def test_mark_all_owner_notifications_read(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.patch(
            "/api/notifications/owner/read-all"
        )

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert "updated_count" in data
    finally:
        clear_auth(client)


def test_mark_all_admin_notifications_read(client: TestClient):
    staff_auth(client, "admin")

    try:
        response = client.patch(
            "/api/notifications/admin/read-all"
        )

        assert response.status_code == 200
        assert response.json()["success"] is True
    finally:
        clear_auth(client)


def test_mark_single_owner_notification_read(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.patch(
            f"/api/notifications/owner/{ObjectId()}/read"
        )

        assert response.status_code in (200, 404)
    finally:
        clear_auth(client)


def test_mark_single_admin_notification_read(client: TestClient):
    staff_auth(client, "admin")

    try:
        response = client.patch(
            f"/api/notifications/admin/{ObjectId()}/read"
        )

        assert response.status_code in (200, 404)
    finally:
        clear_auth(client)


def test_mark_staff_notification_invalid_id(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.patch(
            "/api/notifications/owner/invalid-id/read"
        )

        assert response.status_code == 400
    finally:
        clear_auth(client)


def test_customer_cannot_access_staff_notifications(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/notifications/owner")

        assert response.status_code == 403
    finally:
        clear_auth(client)