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
