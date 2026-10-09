from pydantic import BaseModel, Field
from typing import List, Optional

class TimetableEntry(BaseModel):
    id: str = Field(description="Unique identifier for the class entry")
    subject: str = Field(description="Subject or course name/code (e.g. MATH101, Computer Science, Biology)")
    course_name: str = Field(default="", description="Full course title or duplicate of subject")
    day: str = Field(description="Standard 3 or 4 letter day abbreviation in uppercase: MON, TUE, WED, THUR, FRI, SAT, SUN")
    day_of_week: str = Field(description="Full day of the week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday")
    start_time: str = Field(description="Class start time in format like 09:00, 9:30 AM, 13:00")
    end_time: str = Field(description="Class end time in format like 10:30, 11:00 AM, 14:30")
    room: str = Field(default="", description="Classroom, lecture hall, or lab (e.g. Room 304, Lab B)")
    location: str = Field(default="", description="Location or room name")
    instructor: str = Field(default="", description="Professor, teacher, or instructor name")
    color_code: str = Field(default="0xFFE8CACF", description="Hex pastel color for mobile card UI (e.g. 0xFFE8CACF, 0xFFCDE6E2, 0xFFDBD3EE, 0xFFEFCCB8, 0xFFE9CCAA, 0xFFBDE4C9, 0xFFB5E2FA)")

class TimetableAnalysisResponse(BaseModel):
    is_timetable: bool = Field(description="True if the uploaded document/image is a valid timetable/schedule, False otherwise")
    reasoning: str = Field(description="Explanation of what schedule or document content was identified")
    entries: List[TimetableEntry] = Field(default_factory=list, description="Extracted timetable classes/sessions")
