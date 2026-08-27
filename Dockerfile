# ─────────────────────────────────────────────────────────────────────────────
# AI Study Buddy — Production-grade Dockerfile
#
# Multi-stage build:
#   Stage 1 (builder): install Python dependencies into a clean virtual env
#   Stage 2 (runtime): copy only the venv + app code — no build tools
#
# Security hardening:
#   - Non-root user (appuser)
#   - Read-only filesystem for app code
#   - Minimal base image (python:3.12-slim)
#   - No dev dependencies in final image
# ─────────────────────────────────────────────────────────────────────────────

# ── Stage 1: dependency builder ───────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# System deps needed only at build time
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create isolated virtualenv so it's easy to copy to runtime stage
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt


# ── Stage 2: production runtime ───────────────────────────────────────────────
FROM python:3.12-slim AS runtime

LABEL org.opencontainers.image.title="AI Study Buddy"
LABEL org.opencontainers.image.description="AI-powered study assistant"
LABEL org.opencontainers.image.licenses="MIT"

# Runtime system deps only (libpq for asyncpg)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Non-root user for security
RUN groupadd --gid 1001 appgroup \
 && useradd --uid 1001 --gid appgroup --shell /bin/bash --create-home appuser

WORKDIR /app

# Copy virtualenv from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy application code
COPY --chown=appuser:appgroup . .

# Ensure uploads directory is writable by appuser
RUN mkdir -p /app/uploads && chown -R appuser:appgroup /app/uploads

USER appuser

EXPOSE 8000

# Health check used by Docker and docker-compose
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Production server: multiple workers, no reload
# Workers = 2 * CPU + 1 is the gunicorn recommendation; adjust via WORKERS env
CMD ["uvicorn", "app.main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "2", \
     "--access-log", \
     "--log-level", "info", \
     "--proxy-headers", \
     "--forwarded-allow-ips", "*"]
