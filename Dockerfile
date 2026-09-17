# ---------- build stage ----------
FROM python:3.12-slim AS builder

WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---------- runtime stage ----------
FROM python:3.12-slim

# Create non-root user
RUN groupadd -r novapay && useradd -r -g novapay -u 10001 novapay

WORKDIR /app

# Copy only what we need
COPY --from=builder /install /usr/local
COPY app/ ./app/

# Drop privileges
USER 10001

ENV PYTHONUNBUFFERED=1
ENV APP_VERSION=0.1.0

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
