import logging
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.core.firebase import init_firebase, verify_token
from contextlib import asynccontextmanager

from app.api.endpoints import upload, timetable
from app.api.routes import auth as auth_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("app.main")

# ---------------------------------------------------------------------------
# Routes that do NOT require authentication
# ---------------------------------------------------------------------------
PUBLIC_PATHS = {
    "/health",
    "/docs",
    "/redoc",
    "/openapi.json",
}


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize Firebase on startup
    init_firebase()
    yield


app = FastAPI(
    title="Custom Syllabus API",
    description="Backend for the AI-powered Timetable Management Mobile App",
    version="1.0.0",
    lifespan=lifespan,
)

# ---------------------------------------------------------------------------
# CORS middleware
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=[origin.strip() for origin in settings.allowed_origins.split(",")],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Auth middleware — verifies Firebase ID token for all non-public routes
# ---------------------------------------------------------------------------
@app.middleware("http")
async def firebase_auth_middleware(request: Request, call_next):
    path = request.url.path

    # Skip auth for public / framework paths
    if path in PUBLIC_PATHS or path.startswith("/docs") or path.startswith("/redoc"):
        return await call_next(request)

    # Extract Bearer token
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={"detail": "Missing or invalid Authorization header. Use: Bearer <Firebase ID token>"},
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = auth_header.split(" ", 1)[1].strip()

    # Allow the hard-coded test token in development
    if token == "test-token" and settings.app_env == "development":
        request.state.user = {"uid": "test_user_id", "email": "test@example.com"}
        return await call_next(request)

    try:
        decoded = verify_token(token)
        # Attach decoded claims to request state for downstream use
        request.state.user = decoded
    except Exception as e:
        logger.warning("Auth middleware rejected token: %s", e)
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={"detail": f"Invalid or expired Firebase token: {str(e)}"},
            headers={"WWW-Authenticate": "Bearer"},
        )

    return await call_next(request)


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.get("/health", tags=["health"])
def health_check():
    return {"status": "ok", "environment": settings.app_env}


app.include_router(auth_router.router)
app.include_router(upload.router)
app.include_router(timetable.router)
