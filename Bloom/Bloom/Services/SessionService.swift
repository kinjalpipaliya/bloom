import Foundation
import Supabase

final class SessionService {
    static let shared = SessionService()

    private init() {}

    func fetchFeaturedSessions() async throws -> [Session] {
        let response = try await SupabaseManager.shared.client
            .from("sessions")
            .select()
            .eq("is_featured", value: true)
            .execute()

        return try JSONDecoder().decode([Session].self, from: response.data)
    }

    func fetchAllSessions() async throws -> [Session] {
        let response = try await SupabaseManager.shared.client
            .from("sessions")
            .select()
            .execute()

        return try JSONDecoder().decode([Session].self, from: response.data)
    }
}
