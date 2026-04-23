import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    VOICE_PROVIDER: str = os.getenv("VOICE_PROVIDER", "elevenlabs")
    VOICE_PROVIDER_API_KEY: str = os.getenv("VOICE_PROVIDER_API_KEY", "")
    GENERATED_AUDIO_BUCKET: str = os.getenv("GENERATED_AUDIO_BUCKET", "generated-audio")
    VOICE_SAMPLES_BUCKET: str = os.getenv("VOICE_SAMPLES_BUCKET", "voice-samples")
    APP_ENV: str = os.getenv("APP_ENV", "development")


settings = Settings()
