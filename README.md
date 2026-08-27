# 🎓 AI Study Buddy

> A **production-ready**, AI-powered study companion built with **FastAPI**, **PostgreSQL**, **JWT auth**, and a responsive vanilla frontend — supporting both **IBM watsonx.ai** and **OpenAI**.

[![CI](https://github.com/yourusername/ai-study-buddy/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/ai-study-buddy/actions/workflows/ci.yml)
[![Python 3.12](https://img.shields.io/badge/Python-3.12-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-green.svg)](https://fastapi.tiangolo.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

| Feature | Description |
|---|---|
| 📄 **Document Upload** | Upload PDF, TXT, MD, DOCX — auto text extraction & AI summary |
| 🤖 **AI Summarization** | Concise, detailed, or bullet-point summaries + key concept extraction |
| 🧠 **Quiz Generation** | Auto-generated multiple-choice quizzes with explanations (easy/medium/hard) |
| 🃏 **Flashcard Decks** | AI-created flashcards with SM-2 spaced repetition scheduling |
| 💬 **AI Tutor Chat** | Conversational tutoring grounded in your uploaded documents |
| 📊 **Analytics Dashboard** | Score trends, study streaks, heatmap, document type breakdown |
| 🎯 **Personalized Recommendations** | Data-driven next steps based on quiz performance and generated resources |
| 🔐 **Secure Auth** | JWT access + refresh tokens, bcrypt passwords, rate limiting |
| 🛡 **Security Headers** | HSTS, X-Frame-Options, CSP, X-Content-Type-Options on every response |
| 🚀 **Production Docker** | Multi-stage Dockerfile, non-root user, health checks, Alembic migrations |

---

## 🏗 Project Structure

```
study-buddy/
├── app/
│   ├── main.py              # FastAPI app, security middleware, rate limiting
│   ├── config.py            # Pydantic Settings — all config via environment
│   ├── database.py          # SQLAlchemy async engine & session factory
│   ├── models.py            # ORM models (User, Document, Quiz, Flashcard, Chat…)
│   ├── schemas.py           # Pydantic request/response schemas
│   ├── routes/
│   │   ├── auth.py          # POST /auth/register, /login, GET/PUT /me
│   │   ├── documents.py     # Upload, list, detail, summarize, delete
│   │   ├── quizzes.py       # Generate, take, submit (auto-scored), attempts
│   │   ├── flashcards.py    # Generate deck, study, SM-2 review, due queue
│   │   ├── chat.py          # Sessions, messages, AI tutor
│   │   ├── analytics.py     # Aggregated stats, streaks, heatmaps
│   │   └── study_sessions.py# Time tracking (start/end)
│   └── services/
│       ├── ai_service.py    # LLM dispatcher (OpenAI / IBM watsonx.ai) + retry
│       ├── auth_service.py  # JWT helpers, bcrypt, FastAPI dependencies
│       └── document_service.py  # File save, MIME validation, text extraction
├── alembic/                 # Database migration scripts
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│       └── 001_initial_schema.py
├── tests/                   # pytest test suite (~70%+ coverage)
│   ├── conftest.py          # Fixtures: in-memory DB, async client, AI mocks
│   ├── test_auth_service.py # Unit: bcrypt, JWT encode/decode
│   ├── test_auth_routes.py  # Integration: register, login, profile
│   ├── test_documents.py    # Integration: upload, list, CRUD
│   ├── test_quizzes.py      # Integration: generate, submit, scoring
│   ├── test_flashcards.py   # Integration: generate, SM-2 review
│   ├── test_chat.py         # Integration: sessions, messages
│   ├── test_analytics.py    # Integration: summary, streaks
│   ├── test_health.py       # Health/readiness, security headers
│   └── test_study_sessions.py
├── frontend/
│   ├── index.html           # Single-page application shell (7 pages)
│   └── static/
│       ├── style.css        # Design system (dark mode, responsive)
│       └── app.js           # SPA controller (no framework)
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions CI pipeline
├── Dockerfile               # Multi-stage build, non-root user
├── docker-compose.yml       # Production: db + migrate + app
├── docker-compose.dev.yml   # Development overrides (hot reload)
├── docker-compose.test.yml  # CI test environment
├── alembic.ini
├── pytest.ini
├── requirements.txt
└── .env.example
```

---

## 🚀 Quick Start

### Option A — Docker Compose (recommended)

```bash
cd study-buddy

# 1. Copy and configure environment
cp .env.example .env
#    Required: set SECRET_KEY and OPENAI_API_KEY (or watsonx credentials)
#    SECRET_KEY: openssl rand -hex 32

# 2. Build and launch (runs migrations automatically)
docker compose up --build

# 3. Open the app
open http://localhost:8000

# 4. View API docs (available when DEBUG=True)
open http://localhost:8000/docs
```

### Option B — Local Python

```bash
cd study-buddy

# 1. Create virtualenv
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt
pip install aiosqlite             # only needed for tests

# 3. Start PostgreSQL via Docker
docker run -d --name sb-db \
  -e POSTGRES_USER=studybuddy \
  -e POSTGRES_PASSWORD=studybuddy \
  -e POSTGRES_DB=studybuddy \
  -p 5432:5432 postgres:16-alpine

# 4. Configure environment
cp .env.example .env
# In .env: change DATABASE_URL host from 'db' to 'localhost'
# Set DEBUG=True for local development

# 5. Run database migrations
alembic upgrade head

# 6. Start the server with hot reload
uvicorn app.main:app --reload --port 8000 --log-level debug

# 7. Open the app
open http://localhost:8000
```

### Option C — Development with Docker (hot reload)

```bash
cd study-buddy
cp .env.example .env
# Edit .env: set DEBUG=True and your API keys

docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

---

## 🧪 Running Tests

```bash
# Install test dependencies
pip install -r requirements.txt aiosqlite

# Run the full test suite with coverage
pytest

# Run only fast unit tests (no DB, no slow AI tests)
pytest -m unit

# Run with verbose output and stop on first failure
pytest -x -v

# Generate HTML coverage report
pytest --cov=app --cov-report=html
open htmlcov/index.html
```

Tests use **in-memory SQLite** and **mocked AI calls** — no PostgreSQL or API keys needed.

---

## ⚙️ Configuration Reference

All configuration is driven by environment variables (loaded from `.env`):

| Variable | Default | Required | Description |
|---|---|---|---|
| `SECRET_KEY` | — | ✅ | JWT signing secret (`openssl rand -hex 32`) |
| `DATABASE_URL` | `postgresql+asyncpg://…` | ✅ | Async PostgreSQL connection URL |
| `AI_PROVIDER` | `openai` | ✅ | `openai` or `watsonx` |
| `OPENAI_API_KEY` | — | If using OpenAI | OpenAI API key |
| `OPENAI_MODEL` | `gpt-4o-mini` | | OpenAI model name |
| `WATSONX_API_KEY` | — | If using watsonx | IBM watsonx.ai API key |
| `WATSONX_PROJECT_ID` | — | If using watsonx | watsonx project ID |
| `WATSONX_URL` | `https://us-south.ml.cloud.ibm.com` | | watsonx endpoint |
| `WATSONX_MODEL` | `meta-llama/llama-3-3-70b-instruct` | | watsonx model |
| `DEBUG` | `False` | | Enables Swagger UI, debug logging |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `1440` | | JWT access token lifetime (24h) |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `30` | | JWT refresh token lifetime |
| `MAX_FILE_SIZE_MB` | `20` | | Maximum upload file size |
| `UPLOAD_DIR` | `uploads` | | Directory for uploaded files |
| `ALLOWED_ORIGINS` | `["http://localhost:8000"]` | | CORS allowed origins |

---

## 🔌 API Reference

Base URL: `http://localhost:8000/api/v1`

Interactive docs: `http://localhost:8000/redoc` (always on) · `/docs` (dev only)

### Authentication
| Method | Path | Description |
|---|---|---|
| `POST` | `/auth/register` | Create account, returns JWT |
| `POST` | `/auth/login` | Login with email+password |
| `POST` | `/auth/refresh` | Rotate access + refresh tokens |
| `GET`  | `/auth/me` | Get current user profile |
| `PUT`  | `/auth/me` | Update display name |
| `POST` | `/auth/change-password` | Change password |

### Documents
| Method | Path | Description |
|---|---|---|
| `POST` | `/documents/upload` | Upload file (background AI processing) |
| `GET`  | `/documents/` | Paginated list with search & status filter |
| `GET`  | `/documents/{id}` | Document detail + summary + key concepts |
| `PATCH` | `/documents/{id}` | Rename document |
| `POST` | `/documents/{id}/summarize` | Re-generate summary (`concise`/`detailed`/`bullet_points`) |
| `POST` | `/documents/{id}/reprocess` | Re-run extraction + AI |
| `GET`  | `/documents/{id}/download` | Download original file |
| `DELETE` | `/documents/{id}` | Delete document + file |

### Quizzes
| Method | Path | Description |
|---|---|---|
| `POST` | `/quizzes/generate` | Generate quiz from document |
| `GET`  | `/quizzes/` | Paginated list |
| `GET`  | `/quizzes/{id}` | Quiz detail with questions |
| `PATCH` | `/quizzes/{id}` | Update title/description |
| `POST` | `/quizzes/{id}/submit` | Submit answers → graded result |
| `GET`  | `/quizzes/{id}/attempts` | Attempt history |
| `DELETE` | `/quizzes/{id}` | Delete quiz |

### Flashcards
| Method | Path | Description |
|---|---|---|
| `POST` | `/flashcards/generate` | Generate deck from document |
| `GET`  | `/flashcards/` | Paginated deck list |
| `GET`  | `/flashcards/{id}` | Deck with all cards |
| `PATCH` | `/flashcards/{id}` | Rename deck |
| `GET`  | `/flashcards/{id}/due` | Cards due for review (SM-2) |
| `POST` | `/flashcards/{id}/cards` | Manually add a card |
| `POST` | `/flashcards/cards/{id}/review` | SM-2 quality review (0–5) |
| `DELETE` | `/flashcards/{id}` | Delete deck + cards |

### Chat
| Method | Path | Description |
|---|---|---|
| `POST` | `/chat/sessions` | Create chat session (optional doc context) |
| `GET`  | `/chat/sessions` | Paginated session list |
| `GET`  | `/chat/sessions/{id}` | Session with message history |
| `PATCH` | `/chat/sessions/{id}` | Rename session |
| `POST` | `/chat/sessions/{id}/messages` | Send message → AI reply |
| `DELETE` | `/chat/sessions/{id}` | Delete session + messages |

### Analytics & Study Sessions
| Method | Path | Description |
|---|---|---|
| `GET`  | `/analytics/summary` | Full dashboard: counts, scores, streak, heatmap |
| `GET`  | `/analytics/recommendations` | Personalised next study actions from saved activity |
| `POST` | `/study-sessions/start` | Start tracking a study activity |
| `POST` | `/study-sessions/{id}/end` | End session with duration + score |

### System
| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Liveness probe (no auth) |
| `GET` | `/ready` | Readiness probe — checks DB (no auth) |

---

## 🛡 Security

| Measure | Implementation |
|---|---|
| Password hashing | bcrypt (12 rounds) |
| Token auth | JWT HS256, access (24h) + refresh (30d) tokens |
| Rate limiting | SlowAPI — 200 req/min per IP (configurable per route) |
| Security headers | `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`, `Referrer-Policy`, `Permissions-Policy`, `HSTS` (production) |
| Input validation | Pydantic v2 with strict email, password length, enum validation |
| CORS | Restricted to `ALLOWED_ORIGINS` — no wildcard in production |
| Ownership checks | Every resource access verifies `owner_id == current_user.id` |
| Non-root Docker | App runs as `appuser` (UID 1001) |

---

## 🗄 Database Migrations

Alembic manages the schema. Never run `create_all` directly in production.

```bash
# Apply all pending migrations
alembic upgrade head

# Check current revision
alembic current

# Generate a new migration after model changes
alembic revision --autogenerate -m "add_column_xyz"

# Roll back one revision
alembic downgrade -1

# Roll back to the initial empty state
alembic downgrade base
```

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Python 3.12, FastAPI 0.111, SQLAlchemy 2 (async) |
| **Database** | PostgreSQL 16 via asyncpg |
| **Migrations** | Alembic 1.13 |
| **Auth** | JWT (python-jose), bcrypt 4.1 |
| **Rate Limiting** | SlowAPI 0.1 |
| **AI (OpenAI)** | OpenAI Python SDK 1.x |
| **AI (IBM)** | ibm-watsonx-ai SDK |
| **Document parsing** | pypdf 4, python-docx 1.1 |
| **Frontend** | Vanilla HTML5, CSS3, JavaScript (no build step) |
| **Testing** | pytest, pytest-asyncio, httpx, in-memory SQLite |
| **Containers** | Docker (multi-stage), Docker Compose |
| **CI** | GitHub Actions |

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
