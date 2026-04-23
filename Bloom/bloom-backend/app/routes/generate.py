from fastapi import APIRouter, HTTPException
from app.schemas.generate import GenerateSessionRequest
from app.services.onboarding_service import get_latest_onboarding_response
from app.services.voice_profile_service import get_voice_profile
from app.services.script_service import build_personalized_script
from app.services.voice_generation_service import generate_voice_audio
from app.services.storage_service import upload_generated_audio
from app.services.generated_session_service import create_generated_session

router = APIRouter(tags=["generation"])


@router.post("/generate-session")
async def generate_session(payload: GenerateSessionRequest):
    onboarding = get_latest_onboarding_response(payload.user_id)
    if not onboarding:
        raise HTTPException(
            status_code=404,
            detail={
                "code": "ONBOARDING_NOT_FOUND",
                "message": "No onboarding response found for this user."
            }
        )

    voice_profile = get_voice_profile(payload.user_id)
    if not voice_profile:
        raise HTTPException(
            status_code=404,
            detail={
                "code": "VOICE_PROFILE_NOT_FOUND",
                "message": "No saved voice sample was found for this user."
            }
        )

    script_payload = build_personalized_script(onboarding)
    generation_result = await generate_voice_audio(
        script_text=script_payload["script_text"],
        voice_profile=voice_profile,
    )

    final_audio_url = generation_result["audio_url"]

    if generation_result["audio_bytes"]:
        file_name = f"{script_payload['title'].lower().replace(' ', '-')}.mp3"
        final_audio_url = upload_generated_audio(
            user_id=payload.user_id,
            file_name=file_name,
            audio_bytes=generation_result["audio_bytes"],
            content_type="audio/mpeg",
        )

    created = create_generated_session(
        user_id=payload.user_id,
        source_voice_profile_id=voice_profile.get("id"),
        title=script_payload["title"],
        subtitle=script_payload["subtitle"],
        script_text=script_payload["script_text"],
        audio_url=final_audio_url,
        generation_status="completed",
        generation_provider=generation_result["provider"],
        provider_job_id=generation_result["provider_job_id"],
        session_type=script_payload["session_type"],
        duration_seconds=generation_result["duration_seconds"],
        cover_emoji=script_payload["cover_emoji"],
    )

    if not created:
        raise HTTPException(
            status_code=500,
            detail={
                "code": "GENERATED_SESSION_INSERT_FAILED",
                "message": "Generated session could not be saved."
            }
        )

    return {
        "success": True,
        "generated_session": created
    }


@router.get("/generated-sessions/{user_id}")
async def get_generated_sessions(user_id: str):
    from app.db import supabase

    response = (
        supabase.table("generated_sessions")
        .select("*")
        .eq("user_id", user_id)
        .order("created_at", desc=True)
        .execute()
    )

    return {
        "success": True,
        "sessions": response.data or []
    }


@router.get("/generated-session/{generated_session_id}")
async def get_generated_session(generated_session_id: str):
    from app.db import supabase

    response = (
        supabase.table("generated_sessions")
        .select("*")
        .eq("id", generated_session_id)
        .limit(1)
        .execute()
    )

    rows = response.data or []
    if not rows:
        raise HTTPException(
            status_code=404,
            detail={
                "code": "GENERATED_SESSION_NOT_FOUND",
                "message": "Generated session was not found."
            }
        )

    return {
        "success": True,
        "generated_session": rows[0]
    }
