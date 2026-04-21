import Foundation

struct SavedSession: Identifiable, Decodable {
    let id: UUID
    let user_id: UUID
    let session_id: UUID
    let created_at: String
}
