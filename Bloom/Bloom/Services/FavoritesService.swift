import Foundation
import Supabase

final class FavoritesService {
    static let shared = FavoritesService()

    private init() {}

    struct SavedSessionInsert: Encodable {
        let user_id: UUID
        let session_id: UUID
    }

    func fetchSavedSessionIDs(for userId: UUID) async throws -> Set<UUID> {
        let response = try await SupabaseManager.shared.client
            .from("user_saved_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()

        let rows = try JSONDecoder().decode([SavedSession].self, from: response.data)
        return Set(rows.map(\.session_id))
    }

    func saveSession(userId: UUID, sessionId: UUID) async throws {
        let payload = SavedSessionInsert(
            user_id: userId,
            session_id: sessionId
        )

        try await SupabaseManager.shared.client
            .from("user_saved_sessions")
            .insert(payload)
            .execute()
    }

    func removeSavedSession(userId: UUID, sessionId: UUID) async throws {
        try await SupabaseManager.shared.client
            .from("user_saved_sessions")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("session_id", value: sessionId.uuidString)
            .execute()
    }

    func toggleSavedSession(userId: UUID, sessionId: UUID, isCurrentlySaved: Bool) async throws {
        if isCurrentlySaved {
            try await removeSavedSession(userId: userId, sessionId: sessionId)
        } else {
            try await saveSession(userId: userId, sessionId: sessionId)
        }
    }
}
