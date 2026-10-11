import logging
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, List
from pydantic import BaseModel
from app.services.firestore_service import firestore_service
from app.api.dependencies import get_current_user

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["Timetable & Auth"])

class TimetablePayload(BaseModel):
    entries: List[Dict[str, Any]]
    summary: str = ""

class UserProfilePayload(BaseModel):
    display_name: str = ""
    email: str = ""
    photo_url: str = ""

@router.get("/db/status")
async def get_db_status():
    """Checks whether Firestore is connected."""
    connected = firestore_service.is_connected()
    return {
        "connected": connected,
        "message": "Firestore connected successfully" if connected else "Firestore not configured with credentials yet"
    }

@router.post("/timetable/save")
async def save_timetable(
    payload: TimetablePayload,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Saves user's timetable entries to Firestore."""
    user_id = current_user.get("uid") or current_user.get("user_id") or "default_user"
    success = await firestore_service.save_timetable(user_id, payload.model_dump())
    if not success and not firestore_service.is_connected():
        return {
            "saved_to_cloud": False,
            "message": "Saved locally on client. Cloud DB credentials pending."
        }
    return {
        "saved_to_cloud": success,
        "count": len(payload.entries),
        "message": "Timetable saved to Firestore" if success else "Failed to save to Firestore"
    }

@router.get("/timetable/")
async def get_timetable(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Retrieves user's timetable from Firestore."""
    user_id = current_user.get("uid") or current_user.get("user_id") or "default_user"
    data = await firestore_service.get_timetable(user_id)
    if not data:
        return {"entries": [], "found": False}
    return {"entries": data.get("entries", []), "found": True, "updated_at": data.get("updated_at")}

@router.post("/auth/sync-user")
async def sync_user_profile(
    profile: UserProfilePayload,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Syncs Google Auth user profile to Firestore."""
    user_id = current_user.get("uid") or current_user.get("user_id") or "default_user"
    success = await firestore_service.save_user_profile(user_id, profile.model_dump())
    return {
        "synced": success,
        "user_id": user_id,
        "email": profile.email
    }
