from uuid import UUID
from app.db import supabase


def create_generated_session(
    user_id: UUID,
    source_voice_profile_id,
    title: str,
    subtitle: str,
    script_text: str,
    audio_url: str,
    generation_status: str,
    generation_provider: str,
    provider_job_id,
    session_type: str,
    duration_seconds: int | None,
    cover_emoji: str | None,
):
    payload = {
        "user_id": str(user_id),
        "source_voice_profile_id": str(source_voice_profile_id) if source_voice_profile_id else None,
        "title": title,
        "subtitle": subtitle,
        "script_text": script_text,
        "audio_url": audio_url,
        "generation_status": generation_status,
        "generation_provider": generation_provider,
        "provider_job_id": provider_job_id,
        "session_type": session_type,
        "duration_seconds": duration_seconds,
        "cover_emoji": cover_emoji,
    }

    response = supabase.table("generated_sessions").insert(payload).execute()
    rows = response.data or []
    return rows[0] if rows else None
