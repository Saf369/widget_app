from fastapi import APIRouter, UploadFile, File, HTTPException, status
from typing import Dict, Any
import logging
from app.services.ai_service import extract_timetable
from app.core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter()

ALLOWED_EXTENSIONS = {".pdf", ".png", ".jpg", ".jpeg", ".webp"}

@router.post("/analyze-timetable/", response_model=Dict[str, Any])
async def analyze_timetable(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Accepts an uploaded timetable PDF or PNG/JPG/WEBP image,
    processes it via Gemini multimodal AI pipeline,
    and returns the structured class schedule.
    """
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="No file provided. Please select a PDF or image file."
        )

    # Validate file extension
    filename_lower = file.filename.lower()
    if not any(filename_lower.endswith(ext) for ext in ALLOWED_EXTENSIONS):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported file type. Please upload a PDF or PNG/JPG/WEBP image."
        )

    try:
        # Read file bytes
        file_bytes = await file.read()
        
        # Check file size (e.g., 15MB limit)
        max_bytes = settings.max_upload_size_mb * 1024 * 1024
        if len(file_bytes) > max_bytes:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail=f"File exceeds maximum size limit of {settings.max_upload_size_mb}MB."
            )

        if len(file_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty."
            )

        logger.info(f"Processing uploaded timetable: {file.filename} ({len(file_bytes)} bytes)")

        # Extract timetable using Gemini Multimodal AI
        result = await extract_timetable(
            file_bytes=file_bytes,
            filename=file.filename,
            content_type=file.content_type,
        )

        return result.model_dump()

    except HTTPException:
        raise
    except ValueError as ve:
        logger.warning(f"Validation error analyzing timetable: {ve}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logger.exception(f"Unexpected error analyzing timetable: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process timetable: {str(e)}"
        )
