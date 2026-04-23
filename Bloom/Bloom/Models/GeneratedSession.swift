import Foundation

struct GeneratedSession: Identifiable, Decodable, Hashable {
    let id: UUID
    let user_id: UUID
    let source_voice_profile_id: UUID?
    let title: String
    let subtitle: String?
    let script_text: String
    let audio_url: String
    let generation_status: String
    let generation_provider: String?
    let provider_job_id: String?
    let session_type: String
    let duration_seconds: Int?
    let cover_emoji: String?
    let created_at: String
    let updated_at: String
}

struct GenerateSessionResponse: Decodable {
    let success: Bool
    let generated_session: GeneratedSession
}
