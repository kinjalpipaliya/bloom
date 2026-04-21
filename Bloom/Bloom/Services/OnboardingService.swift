import Foundation
import Supabase

final class OnboardingService {
    static let shared = OnboardingService()

    private init() {}

    struct OnboardingInsert: Encodable {
        let user_id: UUID
        let moods: [String]
        let intentions: [String]
        let blockers: [String]
        let patterns: [String]
        let energy: String
        let reaction: String
        let support_style: String
    }

    func saveOnboarding(
        userId: UUID,
        moods: [String],
        intentions: [String],
        blockers: [String],
        patterns: [String],
        energy: String,
        reaction: String,
        supportStyle: String
    ) async throws {
        let payload = OnboardingInsert(
            user_id: userId,
            moods: moods,
            intentions: intentions,
            blockers: blockers,
            patterns: patterns,
            energy: energy,
            reaction: reaction,
            support_style: supportStyle
        )

        try await SupabaseManager.shared.client
            .from("onboarding_responses")
            .insert(payload)
            .execute()
    }
}
