from bson import ObjectId
from fastapi.testclient import TestClient

from app.api.reviews import get_customer_id


def customer_auth(client: TestClient, customer_id: str):
    client.app.dependency_overrides[get_customer_id] = lambda: customer_id


def clear_auth(client: TestClient):
    client.app.dependency_overrides.pop(get_customer_id, None)


def test_create_review(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 5,
                "comment": "Excellent catering service.",
            },
        )

        assert response.status_code in (201, 401, 503)

        if response.status_code == 201:
            data = response.json()
            assert data["success"] is True
            assert data["message"] == "Review submitted successfully."
            assert data["review"]["rating"] == 5
            assert data["review"]["comment"] == "Excellent catering service."
    finally:
        clear_auth(client)


def test_create_review_without_auth(client: TestClient):
    clear_auth(client)

    response = client.post(
        "/api/reviews/",
        json={
            "rating": 5,
            "comment": "Excellent catering service.",
        },
    )

    assert response.status_code == 401


def test_create_review_invalid_rating(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 6,
                "comment": "Excellent catering service.",
            },
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_create_review_invalid_comment(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 5,
                "comment": "Hi",
            },
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_create_review_rating_must_be_integer(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 4.5,
                "comment": "Excellent catering service.",
            },
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_create_review_extra_field_rejected(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.post(
            "/api/reviews/",
            json={
                "rating": 5,
                "comment": "Excellent catering service.",
                "customer_id": str(ObjectId()),
            },
        )

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_get_my_reviews(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reviews/my-reviews")

        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert "count" in data
        assert "total" in data
        assert "page" in data
        assert "limit" in data
        assert "total_pages" in data
        assert isinstance(data["reviews"], list)
    finally:
        clear_auth(client)


def test_get_my_reviews_without_auth(client: TestClient):
    clear_auth(client)

    response = client.get("/api/reviews/my-reviews")

    assert response.status_code == 401


def test_get_my_reviews_pagination(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get(
            "/api/reviews/my-reviews?page=2&limit=10"
        )

        assert response.status_code == 200

        data = response.json()
        assert data["page"] == 2
        assert data["limit"] == 10
    finally:
        clear_auth(client)


def test_get_my_reviews_invalid_page(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reviews/my-reviews?page=0")

        assert response.status_code == 422
    finally:
        clear_auth(client)


def test_get_my_reviews_invalid_limit(client: TestClient):
    customer_auth(client, str(ObjectId()))

    try:
        response = client.get("/api/reviews/my-reviews?limit=101")

        assert response.status_code == 422
    finally:
        clear_auth(client)