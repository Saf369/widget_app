import logging
from datetime import datetime, timezone
from typing import Optional, Dict, Any, List
from app.core.firebase import get_firestore_client

logger = logging.getLogger(__name__)

class FirestoreService:
    def __init__(self):
        self._db = None

    @property
    def db(self):
        if self._db is None:
            self._db = get_firestore_client()
        return self._db

    def is_connected(self) -> bool:
        return self.db is not None

    async def save_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> bool:
        """Saves or updates user profile in users/{user_id} collection."""
        if not self.db:
            logger.warning("Firestore is not connected. User profile not saved to cloud.")
            return False
        try:
            doc_ref = self.db.collection("users").document(user_id)
            data = {
                **profile_data,
                "updated_at": datetime.now(timezone.utc).isoformat()
            }
            doc_ref.set(data, merge=True)
            logger.info(f"User profile saved for {user_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to save user profile for {user_id}: {e}")
            return False

    async def get_user_profile(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Fetches user profile from users/{user_id}."""
        if not self.db:
            return None
        try:
            doc = self.db.collection("users").document(user_id).get()
            return doc.to_dict() if doc.exists else None
        except Exception as e:
            logger.error(f"Failed to get user profile for {user_id}: {e}")
            return None

    async def save_timetable(self, user_id: str, timetable_data: Dict[str, Any]) -> bool:
        """Saves active timetable in users/{user_id}/timetable/current."""
        if not self.db:
            logger.warning("Firestore is not connected. Timetable not saved to cloud.")
            return False
        try:
            doc_ref = self.db.collection("users").document(user_id).collection("timetable").document("current")
            payload = {
                "user_id": user_id,
                "entries": timetable_data.get("entries", []),
                "summary": timetable_data.get("summary", ""),
                "updated_at": datetime.now(timezone.utc).isoformat()
            }
            doc_ref.set(payload)
            logger.info(f"Timetable saved successfully for {user_id} ({len(payload['entries'])} entries)")
            return True
        except Exception as e:
            logger.error(f"Failed to save timetable for {user_id}: {e}")
            return False

    async def get_timetable(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Retrieves active timetable for user."""
        if not self.db:
            return None
        try:
            doc = self.db.collection("users").document(user_id).collection("timetable").document("current").get()
            return doc.to_dict() if doc.exists else None
        except Exception as e:
            logger.error(f"Failed to get timetable for {user_id}: {e}")
            return None

    async def add_schedule_task(self, user_id: str, task: Dict[str, Any]) -> Optional[str]:
        """Adds a schedule task/entry to users/{user_id}/tasks."""
        if not self.db:
            return None
        try:
            tasks_ref = self.db.collection("users").document(user_id).collection("tasks")
            task_data = {
                **task,
                "created_at": datetime.now(timezone.utc).isoformat()
            }
            _, doc_ref = tasks_ref.add(task_data)
            return doc_ref.id
        except Exception as e:
            logger.error(f"Failed to add task for {user_id}: {e}")
            return None

    async def get_schedule_tasks(self, user_id: str) -> List[Dict[str, Any]]:
        """Gets all tasks for user."""
        if not self.db:
            return []
        try:
            docs = self.db.collection("users").document(user_id).collection("tasks").stream()
            return [{"id": d.id, **d.to_dict()} for d in docs]
        except Exception as e:
            logger.error(f"Failed to get tasks for {user_id}: {e}")
            return []

firestore_service = FirestoreService()
