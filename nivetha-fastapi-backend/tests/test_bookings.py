from datetime import date, timedelta

from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.bookings import customers as customers_collection
from app.api.bookings import (
    get_customer_id,
    require_owner_or_admin,
)


def customer_auth(client: TestClient, customer_id: str):
    client.app.dependency_overrides[get_customer_id] = lambda: customer_id


def staff_auth(client: TestClient, role: str = "owner"):
    client.app.dependency_overrides[require_owner_or_admin] = lambda: {
        "id": role,
        "role": role,
    }


def clear_auth(client: TestClient):
    client.app.dependency_overrides.pop(get_customer_id, None)
    client.app.dependency_overrides.pop(require_owner_or_admin, None)


def create_test_customer():
    customer_id = ObjectId()

    customers_collection.insert_one(
        {
            "_id": customer_id,
            "name": "Test Customer",
            "email": f"{customer_id}@example.com",
            "phone": "9876543210",
        }
    )

    return str(customer_id)


def booking_payload():
    return {
        "function_type": "Birthday",
        "event_date": (date.today() + timedelta(days=30)).isoformat(),
        "event_time": "12:00 PM",
        "location": "Chennai",
        "persons_count": 100,
        "cooking_service": True,
        "serving_staff_required": True,
        "meal_type": "Lunch",
        "food_preference": "Both",
        "special_requirements": "Test booking",
    }


def create_booking(client: TestClient, customer_id: str):
    customer_auth(client, customer_id)

    response = client.post(
        "/api/bookings/",
        json=booking_payload(),
    )

    assert response.status_code == 201

    return response.json()["booking"]


def test_create_booking(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        response = client.post(
            "/api/bookings/",
            json=booking_payload(),
        )

        assert response.status_code == 201

        data = response.json()
        assert data["success"] is True
        assert data["message"] == "Booking request submitted successfully."
        assert data["booking"]["customer_id"] == customer_id
        assert data["booking"]["function_type"] == "Birthday"
        assert data["booking"]["status"] == "pending"
        assert data["booking"]["persons_count"] == 100
        assert data["booking"]["booking_id"].startswith("NIV-")
    finally:
        clear_auth(client)


def test_create_booking_without_auth(client: TestClient):
    clear_auth(client)

    response = client.post(
        "/api/bookings/",
        json=booking_payload(),
    )

    assert response.status_code == 401


def test_create_booking_invalid_data(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        payload = booking_payload()
        payload["persons_count"] = 0

        response = client.post(
            "/api/bookings/",
            json=payload,
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_create_booking_invalid_function_type(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        payload = booking_payload()
        payload["function_type"] = "Invalid Event"

        response = client.post(
            "/api/bookings/",
            json=payload,
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_create_booking_past_event_date(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        payload = booking_payload()
        payload["event_date"] = (
            date.today() - timedelta(days=1)
        ).isoformat()

        response = client.post(
            "/api/bookings/",
            json=payload,
        )

        assert response.status_code == 422
        assert response.json()["detail"] == "Event date cannot be in the past."
    finally:
        clear_auth(client)


def test_create_booking_empty_location(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        payload = booking_payload()
        payload["location"] = "   "

        response = client.post(
            "/api/bookings/",
            json=payload,
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_get_my_bookings(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        create_booking(client, customer_id)

        response = client.get("/api/bookings/my-bookings")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["count"] >= 1
        assert isinstance(data["bookings"], list)
    finally:
        clear_auth(client)


def test_get_my_bookings_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/bookings/my-bookings")

    assert response.status_code == 401


def test_get_all_bookings_owner(client: TestClient):
    customer_id = create_test_customer()
    create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        response = client.get("/api/bookings/owner/all")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["count"] >= 1
        assert isinstance(data["bookings"], list)
    finally:
        clear_auth(client)


def test_get_all_bookings_admin(client: TestClient):
    staff_auth(client, "admin")

    try:
        response = client.get("/api/bookings/owner/all")

        assert response.status_code == 200
        assert response.json()["success"] is True
    finally:
        clear_auth(client)


def test_get_all_bookings_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/bookings/owner/all")

    assert response.status_code == 401


def test_get_owner_booking_by_id(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        response = client.get(
            f"/api/bookings/owner/{booking['booking_id']}"
        )

        assert response.status_code == 200
        assert response.json()["booking"]["booking_id"] == booking["booking_id"]
    finally:
        clear_auth(client)


def test_get_owner_booking_not_found(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.get(
            "/api/bookings/owner/NIV-NOTFOUND"
        )

        assert response.status_code == 404
    finally:
        clear_auth(client)


def test_get_customer_booking_by_id(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    customer_auth(client, customer_id)

    try:
        response = client.get(
            f"/api/bookings/{booking['booking_id']}"
        )

        assert response.status_code == 200
        assert response.json()["booking"]["booking_id"] == booking["booking_id"]
    finally:
        clear_auth(client)


def test_customer_cannot_view_another_customer_booking(client: TestClient):
    first_customer = create_test_customer()
    second_customer = create_test_customer()

    booking = create_booking(client, first_customer)
    customer_auth(client, second_customer)

    try:
        response = client.get(
            f"/api/bookings/{booking['booking_id']}"
        )

        assert response.status_code == 404
    finally:
        clear_auth(client)


def test_get_customer_booking_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get(
        f"/api/bookings/{ObjectId()}"
    )

    assert response.status_code == 401


def test_cancel_pending_booking(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    customer_auth(client, customer_id)

    try:
        response = client.patch(
            f"/api/bookings/{booking['booking_id']}/cancel"
        )

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["booking"]["status"] == "cancelled"
    finally:
        clear_auth(client)


def test_cancel_booking_without_auth(client: TestClient):
    clear_auth(client)

    response = client.patch(
        f"/api/bookings/{ObjectId()}/cancel"
    )

    assert response.status_code == 401


def test_cancel_booking_not_found(client: TestClient):
    customer_id = create_test_customer()
    customer_auth(client, customer_id)

    try:
        response = client.patch(
            "/api/bookings/NIV-NOTFOUND/cancel"
        )

        assert response.status_code == 404
    finally:
        clear_auth(client)


def test_update_booking_status_confirmed(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "confirmed"},
        )

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["booking"]["status"] == "confirmed"
    finally:
        clear_auth(client)


def test_update_booking_status_completed(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        confirm_response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "confirmed"},
        )

        assert confirm_response.status_code == 200

        response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "completed"},
        )

        assert response.status_code == 200
        assert response.json()["booking"]["status"] == "completed"
    finally:
        clear_auth(client)


def test_update_booking_status_rejected(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "admin")

    try:
        response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "rejected"},
        )

        assert response.status_code == 200
        assert response.json()["booking"]["status"] == "rejected"
    finally:
        clear_auth(client)


def test_update_booking_status_invalid_transition(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "completed"},
        )

        assert response.status_code == 409
    finally:
        clear_auth(client)


def test_update_booking_status_invalid_value(client: TestClient):
    customer_id = create_test_customer()
    booking = create_booking(client, customer_id)
    staff_auth(client, "owner")

    try:
        response = client.patch(
            f"/api/bookings/owner/{booking['booking_id']}/status",
            json={"status": "cancelled"},
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_update_booking_status_without_auth(client: TestClient):
    clear_auth(client)

    response = client.patch(
        f"/api/bookings/owner/{ObjectId()}/status",
        json={"status": "confirmed"},
    )

    assert response.status_code == 401


def test_update_booking_status_not_found(client: TestClient):
    staff_auth(client, "owner")

    try:
        response = client.patch(
            "/api/bookings/owner/NIV-NOTFOUND/status",
            json={"status": "confirmed"},
        )

        assert response.status_code == 404
    finally:
        clear_auth(client)