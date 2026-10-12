from fastapi import APIRouter, UploadFile, File, HTTPException, status, Request
from typing import Dict, Any
import logging
from app.services.ai_service import extract_timetable
from app.services.firestore_service import firestore_service
from app.core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter()

ALLOWED_EXTENSIONS = {".pdf", ".png", ".jpg", ".jpeg", ".webp"}

@router.post("/analyze-timetable/", response_model=Dict[str, Any])
async def analyze_timetable(request: Request, file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Accepts an uploaded timetable PDF or PNG/JPG/WEBP image,
    processes it via Gemini multimodal AI pipeline,
    saves it to Firestore for the authenticated user,
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

        result_dict = result.model_dump()

        # If timetable was successfully identified and extracted, store in Firestore
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
                    logger.info(f"Successfully saved timetable to Firestore for user {user_id}: {saved}")
                except Exception as fe:
                    logger.warning(f"Failed to auto-save timetable to Firestore for user {user_id}: {fe}")
                    result_dict["saved_to_firestore"] = False

        return result_dict

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
