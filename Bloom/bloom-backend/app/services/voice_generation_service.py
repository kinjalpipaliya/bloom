from app.config import settings


async def generate_voice_audio(script_text: str, voice_profile: dict) -> dict:
    """
    Replace this with real ElevenLabs call next.
    For now, this starter returns a controlled placeholder result shape.
    """

    sample_audio_url = voice_profile.get("sample_audio_url", "")

    return {
        "audio_bytes": None,
        "audio_url": sample_audio_url,
        "provider": settings.VOICE_PROVIDER,
        "provider_job_id": None,
        "duration_seconds": 60,
    }
