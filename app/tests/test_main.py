from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_version():
    r = client.get("/version")
    assert r.status_code == 200
    assert "version" in r.json()

def test_get_wallet():
    r = client.get("/wallets/wal_001")
    assert r.status_code == 200
    assert r.json()["balance_kobo"] == 150000

def test_wallet_not_found():
    r = client.get("/wallets/does-not-exist")
    assert r.status_code == 404
