import Foundation

struct Session: Identifiable, Decodable {
    let id: UUID
    let title: String
    let subtitle: String?
    let category: String
    let session_type: String
    let duration_seconds: Int
    let cover_emoji: String?
    let audio_url: String?
    let script_text: String?
    let is_featured: Bool
}
