import firebase_admin
from firebase_admin import credentials, firestore, storage
from app.core.config import settings
import json

def get_firebase_credentials():
    if not settings.firebase_project_id:
        return None
        
    private_key = settings.firebase_private_key.replace('\\n', '\n')
    
    return credentials.Certificate({
        "type": "service_account",
        "project_id": settings.firebase_project_id,
        "private_key": private_key,
        "client_email": settings.firebase_client_email,
        "client_id": "",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": f"https://www.googleapis.com/robot/v1/metadata/x509/{settings.firebase_client_email}"
    })

firebase_app = None

def init_firebase():
    global firebase_app
    if not firebase_admin._apps:
        creds = get_firebase_credentials()
        if creds:
            firebase_app = firebase_admin.initialize_app(creds, {
                'storageBucket': settings.firebase_storage_bucket
            })
        else:
            # Fallback for local testing without creds, typically shouldn't happen in prod
            firebase_app = firebase_admin.initialize_app()

def get_firestore_client():
    if not firebase_app:
        init_firebase()
    return firestore.client()

def get_storage_client():
    if not firebase_app:
        init_firebase()
    return storage.bucket()
