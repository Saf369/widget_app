import os
import uuid
import json
import logging
from typing import Optional
from google import genai
from google.genai import types
from app.core.config import settings
from app.schemas.timetable import TimetableAnalysisResponse, TimetableEntry

logger = logging.getLogger(__name__)

DAY_NORMALIZATION = {
    "MON": "MON", "MONDAY": "MON",
    "TUE": "TUE", "TUES": "TUE", "TUESDAY": "TUE",
    "WED": "WED", "WEDNESDAY": "WED",
    "THU": "THUR", "THUR": "THUR", "THURS": "THUR", "THURSDAY": "THUR",
    "FRI": "FRI", "FRIDAY": "FRI",
    "SAT": "SAT", "SATURDAY": "SAT",
    "SUN": "SUN", "SUNDAY": "SUN",
}

FULL_DAY_MAP = {
    "MON": "Monday",
    "TUE": "Tuesday",
    "WED": "Wednesday",
    "THUR": "Thursday",
    "FRI": "Friday",
    "SAT": "Saturday",
    "SUN": "Sunday",
}

PASTEL_COLORS = [
    "0xFFE8CACF",  # Rose
    "0xFFCDE6E2",  # Sage
    "0xFFDBD3EE",  # Lavender
    "0xFFEFCCB8",  # Peach
    "0xFFE9CCAA",  # Warm Amber
    "0xFFBDE4C9",  # Soft Green
    "0xFFB5E2FA",  # Soft Blue
]

import asyncio

class GeminiRateLimitException(Exception):
    """Raised when Gemini API request limit or quota is exhausted."""
    def __init__(self, message: str = "Try again after some time limit hit"):
        super().__init__(message)


def is_gemini_rate_limit_error(e: Optional[BaseException]) -> bool:
    """Detects if an exception is caused by Gemini API rate limit or quota exhaustion."""
    if e is None:
        return False
    if isinstance(e, GeminiRateLimitException):
        return True
    if getattr(e, "code", None) == 429 or getattr(e, "status_code", None) == 429:
        return True
    if getattr(e, "status", None) in ("RESOURCE_EXHAUSTED", "429"):
        return True

    err_str = str(e).lower()
    keywords = [
        "429",
        "resource_exhausted",
        "quota",
        "rate limit",
        "ratelimit",
        "too many requests",
        "limit hit",
        "limit of the request",
        "resource has been exhausted",
    ]
    return any(kw in err_str for kw in keywords)

def detect_mime_type(filename: str, content_type: Optional[str] = None, file_bytes: Optional[bytes] = None) -> str:
    # 1. Magic bytes detection (handles Android content URIs or stripped extensions)
    if file_bytes:
        if file_bytes.startswith(b"%PDF"):
            return "application/pdf"
        elif file_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
            return "image/png"
        elif file_bytes.startswith(b"\xff\xd8\xff"):
            return "image/jpeg"
        elif len(file_bytes) >= 12 and file_bytes[:4] == b"RIFF" and file_bytes[8:12] == b"WEBP":
            return "image/webp"

    # 2. File extension detection
    ext = os.path.splitext(filename.lower())[1] if filename else ""
    if ext == ".pdf":
        return "application/pdf"
    elif ext in [".png"]:
        return "image/png"
    elif ext in [".jpg", ".jpeg"]:
        return "image/jpeg"
    elif ext in [".webp"]:
        return "image/webp"

    # 3. Content type header fallback
    if content_type and (content_type.startswith("image/") or content_type == "application/pdf"):
        return content_type

    raise ValueError(f"Unsupported file format: {ext or filename}. Please upload a PDF or PNG/JPG/WEBP image.")

async def check_is_timetable(
    file_bytes: bytes, filename: str, content_type: Optional[str] = None
) -> dict:
    """
    Lightweight AI check: returns {is_timetable: bool, reasoning: str}.
    Does NOT extract entries — much faster than full extraction.
    """
    mime_type = detect_mime_type(filename, content_type, file_bytes=file_bytes)
    api_key = settings.get_gemini_api_key()

    if not api_key:
        raise ValueError("GEMINI_API_KEY is not configured in backend environment.")

    client = genai.Client(api_key=api_key)
    file_part = types.Part.from_bytes(data=file_bytes, mime_type=mime_type)

    check_prompt = (
        "You are an expert at identifying academic timetables and class schedules.\n"
        "Look at the provided document or image and answer ONLY these two things:\n"
        "1. `is_timetable` (boolean): Is this a school/college/university timetable, "
        "lecture schedule, course routine, or class schedule? Answer true if yes, false if no.\n"
        "2. `reasoning` (string): A short, friendly 1-2 sentence explanation of your decision.\n\n"
        "Examples that ARE timetables: weekly lecture schedule, course routine grid, "
        "class timetable with days and times.\n"
        "Examples that are NOT timetables: selfies, receipts, random documents, "
        "menus, plain text without class times.\n\n"
        "Respond ONLY with valid JSON: {\"is_timetable\": true/false, \"reasoning\": \"...\"}"
    )

    from pydantic import BaseModel

    class TimetableCheckResponse(BaseModel):
        is_timetable: bool
        reasoning: str

    preferred = settings.ai_model or "gemini-2.5-flash"
    models_to_try = [preferred]
    for candidate in ["gemini-2.5-flash", "gemini-3.5-flash", "gemini-3.8-flash", "gemini-3.7-flash"]:
        if candidate not in models_to_try:
            models_to_try.append(candidate)

    response = None
    last_error = None
    rate_limit_encountered = False
    for model_name in models_to_try:
        try:
            logger.info("Checking timetable with model: %s", model_name)
            response = await asyncio.wait_for(
                asyncio.to_thread(
                    client.models.generate_content,
                    model=model_name,
                    contents=[file_part, check_prompt],
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=TimetableCheckResponse,
                        temperature=0.0,
                    ),
                ),
                timeout=8.0,
            )
            if response and response.text:
                logger.info("Timetable check completed with model %s", model_name)
                break
        except Exception as e:
            logger.warning("Model %s check error: %s", model_name, e)
            last_error = e
            if is_gemini_rate_limit_error(e):
                rate_limit_encountered = True

    if not response or not response.text:
        if rate_limit_encountered or is_gemini_rate_limit_error(last_error):
            raise GeminiRateLimitException("Try again after some time limit hit")
        raise last_error or RuntimeError("Failed to check timetable with available models")

    import json as _json
    parsed = _json.loads(response.text)
    return {
        "is_timetable": bool(parsed.get("is_timetable", False)),
        "reasoning": str(parsed.get("reasoning", "")),
    }


async def extract_timetable(file_bytes: bytes, filename: str, content_type: Optional[str] = None) -> TimetableAnalysisResponse:
    mime_type = detect_mime_type(filename, content_type, file_bytes=file_bytes)
    api_key = settings.get_gemini_api_key()
    
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not configured in backend environment.")

    client = genai.Client(api_key=api_key)
    file_part = types.Part.from_bytes(data=file_bytes, mime_type=mime_type)

    prompt = (
        "You are an expert AI timetable and class schedule analyzer.\n"
        "Your task is to analyze the provided document or image (PDF or PNG/JPG/WEBP):\n"
        "1. Determine whether it is a school/college/university timetable, lecture schedule, or course routine.\n"
        "2. If it is NOT a timetable or schedule (for example, a random picture, selfie, receipt, plain document without class times), "
        "set `is_timetable` to false and provide a helpful, polite explanation in `reasoning`.\n"
        "3. If it IS a timetable, extract ALL individual class sessions, lectures, labs, recitations, or seminars.\n"
        "   - `subject`: The course/subject title or code (e.g. 'CS101 Intro to Programming', 'Mathematics', 'Digital Design').\n"
        "   - `course_name`: Same as or full title of the subject.\n"
        "   - `day`: Standard abbreviation: MON, TUE, WED, THUR, FRI, SAT, or SUN.\n"
        "   - `day_of_week`: Full name: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.\n"
        "   - `start_time`: Time the class starts (e.g. '09:00', '9:30 AM', '14:00').\n"
        "   - `end_time`: Time the class ends (e.g. '10:30', '11:00 AM', '15:30').\n"
        "   - `room`: Room number, lecture hall, or lab name if visible (or empty string if none).\n"
        "   - `location`: Same as room.\n"
        "   - `instructor`: Teacher or professor name if visible (or empty string if none).\n"
        "   - `color_code`: Assign a distinct pastel hex color for mobile card UI (e.g. 0xFFE8CACF, 0xFFCDE6E2, 0xFFDBD3EE, 0xFFEFCCB8, 0xFFE9CCAA, 0xFFBDE4C9, 0xFFB5E2FA).\n"
        "4. Be thorough and make sure no classes are missed across all days of the week."
    )

    # Model priority: gemini-2.5-flash first (fastest and most stable)
    preferred = settings.ai_model or "gemini-2.5-flash"
    models_to_try = [preferred]
    for candidate in ["gemini-2.5-flash", "gemini-3.5-flash", "gemini-3.8-flash", "gemini-3.7-flash"]:
        if candidate not in models_to_try:
            models_to_try.append(candidate)

    response = None
    last_error = None
    rate_limit_encountered = False
    for model_name in models_to_try:
        try:
            logger.info(f"Extracting timetable using model: {model_name}")
            response = await asyncio.wait_for(
                asyncio.to_thread(
                    client.models.generate_content,
                    model=model_name,
                    contents=[file_part, prompt],
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=TimetableAnalysisResponse,
                        temperature=0.1,
                    ),
                ),
                timeout=65.0
            )
            if response and response.text:
                logger.info(f"Successfully extracted timetable with model {model_name}")
                break
        except Exception as e:
            logger.warning(f"Model {model_name} encountered error or timeout: {e}")
            last_error = e
            if is_gemini_rate_limit_error(e):
                rate_limit_encountered = True

    if not response or not response.text:
        if rate_limit_encountered or is_gemini_rate_limit_error(last_error):
            raise GeminiRateLimitException("Try again after some time limit hit")
        raise last_error or RuntimeError("Failed to extract timetable with available models")

    # Parse response
    result_json = json.loads(response.text)
    result = TimetableAnalysisResponse.model_validate(result_json)

    # Sanitize and post-process entries
    sanitized_entries = []
    for idx, entry in enumerate(result.entries):
        # Normalize Day
        cleaned_day = entry.day.strip().upper()
        norm_day = DAY_NORMALIZATION.get(cleaned_day, "MON")
        full_day = FULL_DAY_MAP.get(norm_day, "Monday")

        # Normalize subject/course_name
        subj = entry.subject.strip() or entry.course_name.strip() or f"Class {idx + 1}"
        course_name = entry.course_name.strip() or subj

        # Normalize room/location
        room = entry.room.strip() or entry.location.strip()
        location = entry.location.strip() or room

        # Color code
        color = entry.color_code.strip() if entry.color_code else PASTEL_COLORS[idx % len(PASTEL_COLORS)]
        if not color.startswith("0xFF"):
            color = PASTEL_COLORS[idx % len(PASTEL_COLORS)]

        entry_id = entry.id.strip() if entry.id else str(uuid.uuid4())

        sanitized_entries.append(
            TimetableEntry(
                id=entry_id,
                subject=subj,
                course_name=course_name,
                day=norm_day,
                day_of_week=full_day,
                start_time=entry.start_time.strip(),
                end_time=entry.end_time.strip(),
                room=room,
                location=location,
                instructor=entry.instructor.strip(),
                color_code=color,
            )
        )

    result.entries = sanitized_entries
    return result
