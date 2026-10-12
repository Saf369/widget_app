import logging
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.api.dependencies import get_current_user
from app.core.firebase import get_firestore_client
from google.cloud.firestore_v1 import SERVER_TIMESTAMP

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/auth", tags=["auth"])


class SyncUserRequest(BaseModel):
    display_name: str = ""
    email: str = ""
    photo_url: str = ""


@router.post("/sync-user", summary="Sync authenticated Firebase user to Firestore")
async def sync_user(
    body: SyncUserRequest,
    decoded: dict = Depends(get_current_user),
):
    """
    Upserts a `users/{uid}` document in Firestore with the latest
    display_name, email, photo_url, and sign-in timestamp.
    """
    uid = decoded.get("uid")
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token missing UID claim.",
        )

    db = get_firestore_client()
    if db is None:
        logger.warning("Firestore unavailable — skipping server-side sync for uid=%s", uid)
        return {"status": "skipped", "reason": "Firestore unavailable"}

    doc_ref = db.collection("users").document(uid)
    doc = doc_ref.get()

    firebase_claim = decoded.get("firebase", {})
    providers = list(firebase_claim.get("identities", {}).keys()) if isinstance(firebase_claim, dict) else []

    update_data = {
        "uid": uid,
        "email": body.email or decoded.get("email", ""),
        "displayName": body.display_name or decoded.get("name", ""),
        "photoURL": body.photo_url or decoded.get("picture", ""),
        "lastSignInAt": SERVER_TIMESTAMP,
        "providers": providers,
    }

    if not doc.exists:
        update_data["createdAt"] = SERVER_TIMESTAMP
        doc_ref.set(update_data)
        logger.info("Created Firestore user doc for uid=%s", uid)
        return {"status": "created", "uid": uid}
    else:
        doc_ref.update({
            "email": update_data["email"],
            "displayName": update_data["displayName"],
            "photoURL": update_data["photoURL"],
            "lastSignInAt": update_data["lastSignInAt"],
            "providers": update_data["providers"],
        })
        logger.info("Updated Firestore user doc for uid=%s", uid)
        return {"status": "updated", "uid": uid}


@router.get("/me", summary="Get current user from Firestore")
async def get_me(decoded: dict = Depends(get_current_user)):
    """Returns the Firestore user document for the authenticated user."""
    uid = decoded.get("uid")
    db = get_firestore_client()
    if db is None:
        return {"uid": uid, "email": decoded.get("email"), "displayName": decoded.get("name")}

    doc = db.collection("users").document(uid).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="User not found in Firestore.")
    return doc.to_dict()
