from unittest.mock import patch

from fastapi.testclient import TestClient
from pymongo.errors import ServerSelectionTimeoutError


def test_health_check(client: TestClient):
    response = client.get("/health")

    assert response.status_code == 200

    data = response.json()
    assert data["success"] is True
    assert data["status"] == "healthy"
    assert data["message"] == "Nivetha Catering API is running"


@patch("app.api.health.check_mongodb")
def test_database_health_check(mock_check_mongodb, client: TestClient):
    mock_check_mongodb.return_value = None

    response = client.get("/health/database")

    assert response.status_code == 200

    data = response.json()
    assert data["success"] is True
    assert data["status"] == "healthy"
    assert data["message"] == "MongoDB connected successfully"

    mock_check_mongodb.assert_called_once()


@patch("app.api.health.check_mongodb")
def test_database_health_check_connection_error(
    mock_check_mongodb,
    client: TestClient,
):
    mock_check_mongodb.side_effect = ServerSelectionTimeoutError(
        "MongoDB connection failed"
    )

    response = client.get("/health/database")

    assert response.status_code == 503

    data = response.json()
    assert data["detail"]["success"] is False
    assert data["detail"]["status"] == "unhealthy"
    assert data["detail"]["message"] == "MongoDB connection failed"


@patch("app.api.health.check_mongodb")
def test_database_health_check_configuration_error(
    mock_check_mongodb,
    client: TestClient,
):
    mock_check_mongodb.side_effect = RuntimeError(
        "Database configuration unavailable"
    )

    response = client.get("/health/database")

    assert response.status_code == 503

    data = response.json()
    assert data["detail"]["success"] is False
    assert data["detail"]["status"] == "unhealthy"
    assert data["detail"]["message"] == "Database configuration unavailable"


@patch("app.api.health.check_mongodb")
def test_database_health_check_unexpected_error(
    mock_check_mongodb,
    client: TestClient,
):
    mock_check_mongodb.side_effect = Exception("Unexpected database error")

    response = client.get("/health/database")

    assert response.status_code == 503

    data = response.json()
    assert data["detail"]["success"] is False
    assert data["detail"]["status"] == "unhealthy"
    assert data["detail"]["message"] == "Database health check unavailable"