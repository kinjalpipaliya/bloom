from uuid import UUID
from app.db import supabase


def get_latest_onboarding_response(user_id: UUID):
    response = (
        supabase.table("onboarding_responses")
        .select("*")
        .eq("user_id", str(user_id))
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )

    rows = response.data or []
    return rows[0] if rows else None
