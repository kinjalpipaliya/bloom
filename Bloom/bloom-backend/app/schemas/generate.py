from pydantic import BaseModel
from uuid import UUID


class GenerateSessionRequest(BaseModel):
    user_id: UUID


class ErrorBody(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    success: bool = False
    error: ErrorBody
