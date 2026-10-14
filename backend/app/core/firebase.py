import os
import logging
import firebase_admin
from firebase_admin import credentials, firestore, storage, auth
from app.core.config import settings

logger = logging.getLogger(__name__)

firebase_app = None

_firestore_client = None
_firestore_attempted = False
_storage_client = None
_storage_attempted = False

def get_firebase_credentials():
    # 1. Check for explicit path or secret file locations (Render, local, etc.)
    env_cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    possible_file_paths = [
        env_cred_path,
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
            try:
                cert = credentials.Certificate(abs_p)
                logger.info(f"Loaded Firebase credentials from file: {abs_p}")
                return cert
            except Exception as e:
                logger.warning(f"Found credential file at {abs_p} but failed to load: {e}")

    # 2. Check environment variables (supports both UPPERCASE and lowercase)
    project_id = (
        settings.firebase_project_id 
        or os.getenv("FIREBASE_PROJECT_ID", "") 
        or os.getenv("firebase_project_id", "")
    ).strip().strip('"').strip("'")
    client_email = (
        settings.firebase_client_email 
        or os.getenv("FIREBASE_CLIENT_EMAIL", "") 
        or os.getenv("firebase_client_email", "")
    ).strip().strip('"').strip("'")
    private_key_raw = (
        settings.firebase_private_key 
        or os.getenv("FIREBASE_PRIVATE_KEY", "") 
        or os.getenv("firebase_private_key", "")
    ).strip().strip('"').strip("'")

    if project_id and client_email and private_key_raw:
        private_key = private_key_raw.replace('\\n', '\n')
        logger.info(f"Loaded Firebase credentials from environment for project: {project_id}")
        try:
            return credentials.Certificate({
                "type": "service_account",
                "project_id": project_id,
                "private_key": private_key,
                "client_email": client_email,
                "client_id": "",
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                "client_x509_cert_url": f"https://www.googleapis.com/robot/v1/metadata/x509/{client_email}"
            })
        except Exception as e:
            logger.warning(f"Failed to create Firebase credentials from environment variables: {e}")

    return None

def init_firebase():
    global firebase_app
    if not firebase_admin._apps:
        creds = get_firebase_credentials()
        options = {}
        if settings.firebase_storage_bucket:
            options['storageBucket'] = settings.firebase_storage_bucket

        if creds:
            try:
                firebase_app = firebase_admin.initialize_app(creds, options if options else None)
                logger.info("Firebase Admin SDK initialized successfully with credentials.")
            except Exception as e:
                logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
                firebase_app = None
        else:
            # Only try ADC if running in a known GCP environment or explicit ADC is configured
            if os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or os.getenv("K_SERVICE") or os.getenv("GAE_INSTANCE"):
                try:
                    firebase_app = firebase_admin.initialize_app(options=options if options else None)
                    logger.info("Firebase Admin SDK initialized with Application Default Credentials.")
                except Exception as e:
                    logger.warning(f"Firebase Admin SDK initialized without active credentials: {e}")
                    firebase_app = None
            else:
                logger.warning(
                    "No Firebase credentials found. Provide serviceAccountKey.json or set "
                    "FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY in environment variables."
                )
                firebase_app = None

def get_firestore_client():
    global _firestore_client, _firestore_attempted
    if _firestore_attempted:
        return _firestore_client
    _firestore_attempted = True

    if not firebase_admin._apps:
        init_firebase()
    if not firebase_admin._apps:
        return None
    try:
        _firestore_client = firestore.client()
        return _firestore_client
    except Exception as e:
        logger.warning(f"Firestore client could not be created: {e}")
        _firestore_client = None
        return None

def get_storage_client():
    global _storage_client, _storage_attempted
    if _storage_attempted:
        return _storage_client
    _storage_attempted = True

    if not firebase_admin._apps:
        init_firebase()
    if not firebase_admin._apps:
        return None
    try:
        _storage_client = storage.bucket()
        return _storage_client
    except Exception as e:
        logger.warning(f"Storage client could not be created: {e}")
        _storage_client = None
        return None

def verify_token(id_token: str):
    """Verifies a Firebase ID token sent from the client."""
    if not firebase_admin._apps:
        init_firebase()
    return auth.verify_id_token(id_token)
