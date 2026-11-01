from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.foods import require_owner_or_admin


def owner_auth(client: TestClient):
    client.app.dependency_overrides[require_owner_or_admin] = lambda: {
        "id": "owner",
        "role": "owner",
    }


def clear_owner_auth(client: TestClient):
    client.app.dependency_overrides.pop(require_owner_or_admin, None)


def test_get_all_foods(client: TestClient):
    response = client.get("/api/foods/")

    assert response.status_code == 200

    data = response.json()
    assert data["success"] is True
    assert "count" in data
    assert isinstance(data["foods"], list)


def test_get_single_food_invalid_id(client: TestClient):
    response = client.get("/api/foods/invalid-id")

    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid food ID."


def test_get_single_food_not_found(client: TestClient):
    response = client.get(f"/api/foods/{ObjectId()}")

    assert response.status_code == 404
    assert response.json()["detail"] == "Food not found."


def test_add_food_without_auth(client: TestClient):
    clear_owner_auth(client)

    response = client.post(
        "/api/foods/",
        json={
            "name": "Chicken Biryani",
            "category": "Non-Veg",
            "description": "Special chicken biryani",
            "is_available": True,
        },
    )

    assert response.status_code == 401


def test_add_food(client: TestClient):
    owner_auth(client)

    try:
        response = client.post(
            "/api/foods/",
            json={
                "name": "Test Biryani",
                "category": "Non-Veg",
                "description": "Test food description",
                "is_available": True,
            },
        )

        assert response.status_code == 201

        data = response.json()
        assert data["success"] is True
        assert data["message"] == "Food added successfully."
        assert data["food"]["name"] == "Test Biryani"
        assert data["food"]["category"] == "Non-Veg"
        assert data["food"]["is_available"] is True
        assert "id" in data["food"]
    finally:
        clear_owner_auth(client)


def test_food_crud_workflow(client: TestClient):
    owner_auth(client)

    try:
        create_response = client.post(
            "/api/foods/",
            json={
                "name": "Test Veg Meals",
                "category": "Veg",
                "description": "Fresh vegetarian meals",
                "is_available": True,
            },
        )

        assert create_response.status_code == 201

        food = create_response.json()["food"]
        food_id = food["id"]

        view_response = client.get(f"/api/foods/{food_id}")

        assert view_response.status_code == 200
        assert view_response.json()["food"]["name"] == "Test Veg Meals"

        update_response = client.patch(
            f"/api/foods/{food_id}",
            json={
                "name": "Updated Veg Meals",
                "description": "Updated description",
            },
        )

        assert update_response.status_code == 200
        assert update_response.json()["food"]["name"] == "Updated Veg Meals"
        assert (
            update_response.json()["food"]["description"]
            == "Updated description"
        )

        delete_response = client.delete(f"/api/foods/{food_id}")

        assert delete_response.status_code == 200
        assert delete_response.json()["success"] is True

        deleted_view_response = client.get(f"/api/foods/{food_id}")

        assert deleted_view_response.status_code == 404

    finally:
        clear_owner_auth(client)


def test_add_food_invalid_data(client: TestClient):
    owner_auth(client)

    try:
        response = client.post(
            "/api/foods/",
            json={
                "name": "A",
                "category": "V",
                "description": "Invalid food",
                "is_available": True,
            },
        )

        assert response.status_code == 422
    finally:
        clear_owner_auth(client)


def test_update_food_without_auth(client: TestClient):
    clear_owner_auth(client)

    response = client.patch(
        f"/api/foods/{ObjectId()}",
        json={"name": "Updated Food"},
    )

    assert response.status_code == 401


def test_update_food_invalid_id(client: TestClient):
    owner_auth(client)

    try:
        response = client.patch(
            "/api/foods/invalid-id",
            json={"name": "Updated Food"},
        )

        assert response.status_code == 400
    finally:
        clear_owner_auth(client)


def test_update_food_empty_data(client: TestClient):
    owner_auth(client)

    try:
        response = client.patch(
            f"/api/foods/{ObjectId()}",
            json={},
        )

        assert response.status_code == 400
    finally:
        clear_owner_auth(client)


def test_delete_food_without_auth(client: TestClient):
    clear_owner_auth(client)

    response = client.delete(f"/api/foods/{ObjectId()}")

    assert response.status_code == 401


def test_delete_food_invalid_id(client: TestClient):
    owner_auth(client)

    try:
        response = client.delete("/api/foods/invalid-id")

        assert response.status_code == 400
    finally:
        clear_owner_auth(client)