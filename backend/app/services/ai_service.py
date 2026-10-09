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

def detect_mime_type(filename: str, content_type: Optional[str] = None) -> str:
    ext = os.path.splitext(filename.lower())[1]
    
    if ext == ".pdf":
        return "application/pdf"
    elif ext in [".png"]:
        return "image/png"
    elif ext in [".jpg", ".jpeg"]:
        return "image/jpeg"
    elif ext in [".webp"]:
        return "image/webp"
    
    if content_type and (content_type.startswith("image/") or content_type == "application/pdf"):
        return content_type
        
    raise ValueError(f"Unsupported file format: {ext or filename}. Please upload a PDF or PNG/JPG image.")

async def extract_timetable(file_bytes: bytes, filename: str, content_type: Optional[str] = None) -> TimetableAnalysisResponse:
    mime_type = detect_mime_type(filename, content_type)
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

    try:
        response = client.models.generate_content(
            model=settings.ai_model,
            contents=[file_part, prompt],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=TimetableAnalysisResponse,
                temperature=0.1,
            ),
        )
    except Exception as e:
        logger.error(f"Gemini API error during timetable extraction: {e}")
        # Try fallback model if configured model had an issue
        if settings.ai_model != "gemini-2.5-flash":
            logger.info("Retrying with gemini-2.5-flash...")
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[file_part, prompt],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    response_schema=TimetableAnalysisResponse,
                    temperature=0.1,
                ),
            )
        else:
            raise

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
