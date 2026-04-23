from pydantic import BaseModel
from uuid import UUID
from typing import Optional


class GeneratedSessionResponse(BaseModel):
    id: UUID
    user_id: UUID
    source_voice_profile_id: Optional[UUID] = None
    title: str
    subtitle: Optional[str] = None
    script_text: str
    audio_url: str
    generation_status: str
    generation_provider: Optional[str] = None
    provider_job_id: Optional[str] = None
    session_type: str
    duration_seconds: Optional[int] = None
    cover_emoji: Optional[str] = None
    created_at: str
    updated_at: str
