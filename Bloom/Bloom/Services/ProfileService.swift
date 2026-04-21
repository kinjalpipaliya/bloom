import Foundation
import Supabase

final class ProfileService {
    static let shared = ProfileService()

    private init() {}

    func fetchLatestOnboardingResponse(for userId: UUID) async throws -> OnboardingResponse? {
        let response = try await SupabaseManager.shared.client
            .from("onboarding_responses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()

        let rows = try JSONDecoder().decode([OnboardingResponse].self, from: response.data)
        return rows.first
    }
}
