import json
import logging
import os
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest
from starlette.responses import Response


# Structured JSON logging
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
        }

        if record.exc_info:
            log_record["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_record)


handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())

logging.basicConfig(
    level=logging.INFO,
    handlers=[handler],
)

logger = logging.getLogger("novapay-wallet")

app = FastAPI(
    title="NovaPay Wallet",
    version="0.1.0",
)


# Custom Prometheus metric
REQUEST_COUNT = Counter(
    "novapay_wallet_requests_total",
    "Total requests to the wallet service",
    ["method", "endpoint", "status"],
)


# In-memory stub (replace with real DB in production)
WALLETS = {
    "wal_001": {
        "id": "wal_001",
        "balance_kobo": 150000,
        "currency": "NGN",
        "owner": "user_123",
    },
    "wal_002": {
        "id": "wal_002",
        "balance_kobo": 50000,
        "currency": "NGN",
        "owner": "user_456",
    },
}


@app.get("/health")
def health():
    REQUEST_COUNT.labels(
        method="GET",
        endpoint="/health",
        status="200",
    ).inc()

    return {"status": "ok"}


@app.get("/ready")
def ready():
    # In real life: check DB connectivity, NIBSS reachability, etc.
    REQUEST_COUNT.labels(
        method="GET",
        endpoint="/ready",
        status="200",
    ).inc()

    return {"status": "ready"}


@app.get("/version")
def version():
    REQUEST_COUNT.labels(
        method="GET",
        endpoint="/version",
        status="200",
    ).inc()

    return {"version": os.getenv("APP_VERSION", "0.1.0")}


@app.get("/wallets/{wallet_id}")
def get_wallet(wallet_id: str):
    wallet = WALLETS.get(wallet_id)

    if not wallet:
        REQUEST_COUNT.labels(
            method="GET",
            endpoint="/wallets/{id}",
            status="404",
        ).inc()

        raise HTTPException(
            status_code=404,
            detail="Wallet not found",
        )

    REQUEST_COUNT.labels(
        method="GET",
        endpoint="/wallets/{id}",
        status="200",
    ).inc()

    logger.info("Retrieved wallet %s", wallet_id)

    return wallet


@app.get("/metrics")
def metrics():
    return Response(
        generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )