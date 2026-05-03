import os
import tempfile
import httpx
from elevenlabs.client import ElevenLabs

from app.config import settings
from app.services.voice_profile_service import update_provider_voice_id


def _download_voice_sample(sample_audio_url: str) -> str:
    print("VOICE SAMPLE URL:", sample_audio_url, flush=True)

    response = httpx.get(sample_audio_url, timeout=60)
    response.raise_for_status()

    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".m4a")
    temp_file.write(response.content)
    temp_file.close()

    return temp_file.name


def _create_instant_voice_clone(client: ElevenLabs, sample_audio_url: str) -> str:
    print("Downloading voice sample...", flush=True)

    sample_path = _download_voice_sample(sample_audio_url)

    print("Saved temp voice sample:", sample_path, flush=True)

    try:
        with open(sample_path, "rb") as audio_file:
            voice = client.voices.ivc.create(
                name="Bloom User Voice",
                description="A personal Bloom affirmation voice created from the user's saved sample.",
                files=[audio_file],
            )

        print("Voice created:", voice.voice_id, flush=True)
        return voice.voice_id

    finally:
        try:
            os.remove(sample_path)
        except OSError:
            pass


async def generate_voice_audio(script_text: str, voice_profile: dict) -> dict:
    if not settings.VOICE_PROVIDER_API_KEY:
        raise ValueError("Missing ElevenLabs API key. Set VOICE_PROVIDER_API_KEY in .env.")

    client = ElevenLabs(api_key=settings.VOICE_PROVIDER_API_KEY)

    user_id = voice_profile.get("user_id")
    sample_audio_url = voice_profile.get("sample_audio_url")
    saved_voice_id = voice_profile.get("provider_voice_id")

    if saved_voice_id:
        voice_id = saved_voice_id
        print("Using cached ElevenLabs voice:", voice_id, flush=True)
    else:
        if not sample_audio_url:
            raise ValueError("Voice profile does not contain sample_audio_url.")

        voice_id = _create_instant_voice_clone(
            client=client,
            sample_audio_url=sample_audio_url,
        )

        if user_id:
            update_provider_voice_id(user_id=user_id, provider_voice_id=voice_id)
            print("Saved ElevenLabs voice_id to user_voice_profiles:", voice_id, flush=True)

    audio_stream = client.text_to_speech.convert(
        voice_id=voice_id,
        model_id="eleven_multilingual_v2",
        text=script_text,
        output_format="mp3_44100_128",
        voice_settings={
            "stability": 0.75,
            "similarity_boost": 0.95,
            "style": 0.25,
            "use_speaker_boost": True,
            "speed": 0.85,
        },
    )

    audio_bytes = b"".join(audio_stream)

    return {
        "audio_bytes": audio_bytes,
        "audio_url": None,
        "provider": settings.VOICE_PROVIDER,
        "provider_job_id": voice_id,
        "duration_seconds": 60,
    }
