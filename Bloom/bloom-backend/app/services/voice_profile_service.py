from uuid import UUID
from app.db import supabase


def get_voice_profile(user_id: UUID):
    response = (
        supabase.table("user_voice_profiles")
        .select("*")
        .eq("user_id", str(user_id))
        .limit(1)
        .execute()
    )

    rows = response.data or []
    return rows[0] if rows else None


def update_provider_voice_id(user_id: UUID, provider_voice_id: str):
    response = (
        supabase.table("user_voice_profiles")
        .update({
            "provider": "elevenlabs",
            "provider_voice_id": provider_voice_id,
        })
        .eq("user_id", str(user_id))
        .execute()
    )

    rows = response.data or []
    return rows[0] if rows else None
