import Foundation

struct OnboardingResponse: Identifiable, Decodable {
    let id: UUID
    let user_id: UUID
    let moods: [String]
    let intentions: [String]
    let blockers: [String]
    let patterns: [String]
    let energy: String?
    let reaction: String?
    let support_style: String?
    let created_at: String
}
