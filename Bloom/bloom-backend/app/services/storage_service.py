from uuid import UUID
from app.db import supabase
from app.config import settings


def upload_generated_audio(user_id: UUID, file_name: str, audio_bytes: bytes, content_type: str = "audio/mpeg") -> str:
    storage_path = f"{user_id}/{file_name}"

    supabase.storage.from_(settings.GENERATED_AUDIO_BUCKET).upload(
        path=storage_path,
        file=audio_bytes,
        file_options={"content-type": content_type, "upsert": "true"},
    )

    public_url = supabase.storage.from_(settings.GENERATED_AUDIO_BUCKET).get_public_url(storage_path)
    return public_url
