from pydantic_settings import BaseSettings, SettingsConfigDict
import os

class Settings(BaseSettings):
    app_env: str = "development"
    firebase_project_id: str = ""
    firebase_client_email: str = ""
    firebase_private_key: str = ""
    firebase_storage_bucket: str = ""
    ai_api_key: str = ""
    gemini_api_key: str = ""
    ai_model: str = "gemini-3.8-flash"
    max_upload_size_mb: int = 15
    allowed_origins: str = "*"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    def get_gemini_api_key(self) -> str:
        return self.gemini_api_key or self.ai_api_key or os.getenv("GEMINI_API_KEY", "") or os.getenv("AI_API_KEY", "")

settings = Settings()
