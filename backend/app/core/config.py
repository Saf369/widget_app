from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_env: str = "development"
    firebase_project_id: str = ""
    firebase_client_email: str = ""
    firebase_private_key: str = ""
    firebase_storage_bucket: str = ""
    ai_api_key: str = ""
    ai_model: str = "gemini-2.5-pro"
    max_upload_size_mb: int = 10
    allowed_origins: str = "*"

    class Config:
        env_file = ".env"

settings = Settings()
