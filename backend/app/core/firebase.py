import os
import logging
import firebase_admin
from firebase_admin import credentials, firestore, storage, auth
from app.core.config import settings

logger = logging.getLogger(__name__)

firebase_app = None

def get_firebase_credentials():
    # 1. Check for serviceAccountKey.json file in backend root, Render secret files, or working directory
    possible_file_paths = [
        os.getenv("GOOGLE_APPLICATION_CREDENTIALS", ""),
        "/etc/secrets/serviceAccountKey.json",
        "/etc/secrets/firebase_credentials.json",
        "serviceAccountKey.json",
        "firebase_credentials.json",
        os.path.join(os.path.dirname(__file__), "..", "..", "serviceAccountKey.json"),
        os.path.join(os.path.dirname(__file__), "..", "..", "firebase_credentials.json"),
    ]
    for p in possible_file_paths:
        if not p:
            continue
        abs_p = os.path.abspath(p)
        if os.path.exists(abs_p):
            logger.info(f"Loaded Firebase credentials from file: {abs_p}")
            return credentials.Certificate(abs_p)

    # 2. Check environment variables
    if settings.firebase_project_id and settings.firebase_client_email and settings.firebase_private_key:
        private_key = settings.firebase_private_key.replace('\\n', '\n')
        logger.info(f"Loaded Firebase credentials from environment for project: {settings.firebase_project_id}")
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

    return None

def init_firebase():
    global firebase_app
    if not firebase_admin._apps:
        creds = get_firebase_credentials()
        options = {}
        if settings.firebase_storage_bucket:
            options['storageBucket'] = settings.firebase_storage_bucket

        if creds:
            firebase_app = firebase_admin.initialize_app(creds, options if options else None)
            logger.info("Firebase Admin SDK initialized successfully with credentials.")
        else:
            try:
                # Try Application Default Credentials if in cloud/GCP environment
                firebase_app = firebase_admin.initialize_app(options=options if options else None)
                logger.info("Firebase Admin SDK initialized with Application Default Credentials.")
            except Exception as e:
                logger.warning(f"Firebase Admin SDK initialized without active credentials: {e}")
                firebase_app = None

def get_firestore_client():
    if not firebase_admin._apps:
        init_firebase()
    if not firebase_admin._apps:
        return None
    try:
        return firestore.client()
    except Exception as e:
        logger.warning(f"Firestore client could not be created: {e}")
        return None

def get_storage_client():
    if not firebase_admin._apps:
        init_firebase()
    if not firebase_admin._apps:
        return None
    try:
        return storage.bucket()
    except Exception as e:
        logger.warning(f"Storage client could not be created: {e}")
        return None

def verify_token(id_token: str):
    """Verifies a Firebase ID token sent from the client."""
    if not firebase_admin._apps:
        init_firebase()
    return auth.verify_id_token(id_token)
