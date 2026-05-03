import Foundation
import Supabase

final class SessionService {
    static let shared = SessionService()
    private init() {}

    struct Session: Decodable, Identifiable {
        let id: UUID
        let title: String
        let subtitle: String
        let audio_url: String
        let script_text: String
        let created_at: String
    }

    func fetchSessions(userId: UUID) async throws -> [Session] {
        let response = try await SupabaseManager.shared.client
            .from("generated_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([Session].self, from: response.data)
    }
}
