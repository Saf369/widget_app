from fastapi import APIRouter, UploadFile, File, HTTPException, status, Request, Body
from typing import Dict, Any, Optional
import logging
import uuid
import time

from app.services.ai_service import extract_timetable, check_is_timetable
from app.services.firestore_service import firestore_service
from app.core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter()

ALLOWED_EXTENSIONS = {".pdf", ".png", ".jpg", ".jpeg", ".webp"}

# ---------------------------------------------------------------------------
# In-memory staging store: file_token -> {bytes, filename, content_type, expires}
# ---------------------------------------------------------------------------
_staged_files: Dict[str, Dict[str, Any]] = {}
_STAGE_TTL_SECONDS = 300  # 5 minutes


def _evict_expired():
    """Remove expired staged files."""
    now = time.time()
    expired = [k for k, v in _staged_files.items() if v["expires"] < now]
    for k in expired:
        del _staged_files[k]


# ---------------------------------------------------------------------------
# STEP 1 — POST /send-file/
# Receives and validates the file, stores it temporarily, returns a token.
# ---------------------------------------------------------------------------
@router.post("/send-file/", response_model=Dict[str, Any])
async def send_file(request: Request, file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Step 1 of the timetable pipeline.
    Validates the uploaded file (type + size) and stages it server-side.
    Returns a short-lived file_token used in subsequent steps.
    """
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No file provided. Please select a PDF or image file.",
        )

    filename_lower = file.filename.lower()
    if not any(filename_lower.endswith(ext) for ext in ALLOWED_EXTENSIONS):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file type. Please upload a PDF or PNG/JPG/WEBP image.",
        )

    file_bytes = await file.read()

    max_bytes = settings.max_upload_size_mb * 1024 * 1024
    if len(file_bytes) > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File exceeds maximum size limit of {settings.max_upload_size_mb}MB.",
        )

    if len(file_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is empty.",
        )

    _evict_expired()

    file_token = str(uuid.uuid4())
    _staged_files[file_token] = {
        "bytes": file_bytes,
        "filename": file.filename,
        "content_type": file.content_type,
        "expires": time.time() + _STAGE_TTL_SECONDS,
    }

    logger.info(
        "Staged file for token %s: %s (%d bytes)", file_token, file.filename, len(file_bytes)
    )

    return {
        "file_token": file_token,
        "filename": file.filename,
        "size_bytes": len(file_bytes),
    }


# ---------------------------------------------------------------------------
# STEP 2 — POST /check-file/
# Uses the staged file to determine whether it looks like a timetable.
# Returns {is_timetable, reasoning}. Does NOT extract entries.
# ---------------------------------------------------------------------------
@router.post("/check-file/", response_model=Dict[str, Any])
async def check_file(request: Request, body: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """
    Step 2 of the timetable pipeline.
    Runs a fast AI check to determine if the staged file is a timetable.
    Returns is_timetable (bool) and reasoning (str).
    If is_timetable is False the client should show an error and stop.
    """
    file_token: str = body.get("file_token", "")
    if not file_token or file_token not in _staged_files:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired file token. Please re-upload your file.",
        )

    staged = _staged_files[file_token]
    if staged["expires"] < time.time():
        del _staged_files[file_token]
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File token has expired. Please re-upload your file.",
        )

    file_bytes: bytes = staged["bytes"]
    filename: str = staged["filename"]
    content_type: Optional[str] = staged["content_type"]

    logger.info("Checking if file is a timetable: %s", filename)

    try:
        result = await check_is_timetable(
            file_bytes=file_bytes,
            filename=filename,
            content_type=content_type,
        )
        return {
            "is_timetable": result["is_timetable"],
            "reasoning": result["reasoning"],
            "file_token": file_token,
        }
    except Exception as e:
        logger.exception("Error during timetable check: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check file: {str(e)}",
        )


# ---------------------------------------------------------------------------
# STEP 3 — POST /analyze-timetable/
# Full extraction. Accepts file_token query param or a fresh multipart upload.
# ---------------------------------------------------------------------------
@router.post("/analyze-timetable/", response_model=Dict[str, Any])
async def analyze_timetable(
    request: Request,
    file: UploadFile = File(None),
) -> Dict[str, Any]:
    """
    Step 3 / legacy endpoint.
    Performs the full AI extraction of timetable entries.
    Pass ?file_token=<token> to reuse a staged file, or upload a fresh file.
    """
    file_token = request.query_params.get("file_token")

    # Resolve file bytes from staged token or fresh upload
    if file_token and file_token in _staged_files:
        staged = _staged_files[file_token]
        if staged["expires"] < time.time():
            del _staged_files[file_token]
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File token expired. Please re-upload.",
            )
        file_bytes = staged["bytes"]
        filename = staged["filename"]
        content_type = staged["content_type"]
        logger.info("Analyzing timetable from staged token %s: %s", file_token, filename)

    elif file is not None and file.filename:
        filename_lower = file.filename.lower()
        if not any(filename_lower.endswith(ext) for ext in ALLOWED_EXTENSIONS):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported file type. Please upload a PDF or PNG/JPG/WEBP image.",
            )
        file_bytes = await file.read()
        filename = file.filename
        content_type = file.content_type

        max_bytes = settings.max_upload_size_mb * 1024 * 1024
        if len(file_bytes) > max_bytes:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail=f"File exceeds maximum size limit of {settings.max_upload_size_mb}MB.",
            )
        if len(file_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty.",
            )
        logger.info("Analyzing timetable from fresh upload: %s (%d bytes)", filename, len(file_bytes))

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No file provided. Supply a file_token query param or upload a file.",
        )

    try:
        result = await extract_timetable(
            file_bytes=file_bytes,
            filename=filename,
            content_type=content_type,
        )

        result_dict = result.model_dump()

        # Auto-save to Firestore on success
        if result.is_timetable and result.entries:
            user = getattr(request.state, "user", None)
            if user and "uid" in user:
                user_id = user["uid"]
                try:
                    entries_data = [e.model_dump() for e in result.entries]
                    saved = await firestore_service.save_timetable(user_id, {
                        "entries": entries_data,
                        "summary": result.reasoning or "Extracted via Gemini AI",
                    })
                    result_dict["saved_to_firestore"] = saved
                    logger.info("Auto-saved timetable to Firestore for user %s", user_id)
                except Exception as fe:
                    logger.warning("Failed to auto-save timetable for user %s: %s", user_id, fe)
                    result_dict["saved_to_firestore"] = False

        # Clean up staged file
        if file_token and file_token in _staged_files:
            del _staged_files[file_token]

        return result_dict

    except HTTPException:
        raise
    except ValueError as ve:
        logger.warning("Validation error analyzing timetable: %s", ve)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logger.exception("Unexpected error analyzing timetable: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process timetable: {str(e)}",
        )
