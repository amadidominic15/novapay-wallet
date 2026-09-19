from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_version():
    response = client.get("/version")

    assert response.status_code == 200
    assert "version" in response.json()


def test_get_wallet():
    response = client.get("/wallets/wal_001")

    assert response.status_code == 200
    assert response.json()["balance_kobo"] == 150000


def test_wallet_not_found():
    response = client.get("/wallets/does-not-exist")

    assert response.status_code == 404