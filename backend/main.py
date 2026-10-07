import os
import json
import tempfile
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

# Load variables from .env file
load_dotenv()

# Initialize the Gemini client. Ensure GEMINI_API_KEY is set in the environment or .env file.
client = genai.Client()

app = FastAPI(title="Timetable AI Analyzer API")

# Add CORS middleware to allow requests from your Flutter web app or mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# Define the expected JSON output structures
# ---------------------------------------------------------
class TimetableEntry(BaseModel):
    day: str = Field(description="Day of the week (e.g., Monday)")
    start_time: str = Field(description="Start time of the lecture (e.g., 09:00 AM)")
    end_time: str = Field(description="End time of the lecture (e.g., 10:00 AM)")
    subject: str = Field(description="Name of the subject or course")
    room: str = Field(description="Room number, building, or location", default="")
    instructor: str = Field(description="Instructor's name or initials", default="")

class TimetableAnalysis(BaseModel):
    is_timetable: bool = Field(description="True if the document appears to be a timetable, False otherwise")
    reasoning: str = Field(description="Brief explanation of why it is or isn't a timetable")
    entries: list[TimetableEntry] = Field(
        description="List of timetable entries if it is a timetable. Empty if not.", 
        default_factory=list
    )

@app.post("/analyze-timetable/", response_model=TimetableAnalysis)
async def analyze_timetable_endpoint(file: UploadFile = File(...)):
    """
    Receives an uploaded timetable image or PDF, analyzes it with Gemini,
    and returns the structured data.
    """
    
    # Validate the file type (basic check)
    valid_mime_types = ["image/jpeg", "image/png", "application/pdf"]
    if file.content_type not in valid_mime_types:
        raise HTTPException(status_code=400, detail="Invalid file type. Only JPEG, PNG, and PDF are allowed.")

    # Save the uploaded file temporarily so the Gemini API can access it
    try:
        # Create a temporary file with the correct extension
        ext = ".pdf" if file.content_type == "application/pdf" else ".jpg" 
        with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as temp_file:
            # Read and write the uploaded file contents
            content = await file.read()
            temp_file.write(content)
            temp_file_path = temp_file.name

        print(f"File temporarily saved to {temp_file_path}")

        # 1. Upload to Gemini
        uploaded_file = client.files.upload(
            file=temp_file_path, 
            config={'mime_type': file.content_type}
        )
        
        prompt = """
        Analyze the attached document. First, determine if it represents a class, school, or university timetable.
        If it IS a timetable, carefully extract all the schedule entries.
        If it is NOT a timetable, set is_timetable to false and explain why in the reasoning field.
        """
        
        # 2. Generate Structured Content
        response = client.models.generate_content(
            model='gemini-2.5-pro',
            contents=[uploaded_file, prompt],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=TimetableAnalysis,
                temperature=0.1, 
            ),
        )

        # 3. Clean up: Delete from Gemini storage and local temp storage
        client.files.delete(name=uploaded_file.name)
        os.remove(temp_file_path)

        # Parse and return JSON response
        result_dict = json.loads(response.text)
        return result_dict

    except Exception as e:
        # Ensure we delete the temp file even if an error occurs
        if 'temp_file_path' in locals() and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
            
        raise HTTPException(status_code=500, detail=f"Error analyzing document: {str(e)}")

@app.get("/")
def root():
    return {"message": "Timetable API is running!"}
