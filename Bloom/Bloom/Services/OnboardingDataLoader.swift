import Foundation

final class OnboardingDataLoader {
    static func load() -> BloomOnboardingContent {
        guard let url = Bundle.main.url(forResource: "onboarding_questions", withExtension: "json") else {
            fatalError("Could not find onboarding_questions.json in app bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(BloomOnboardingContent.self, from: data)
        } catch {
            fatalError("Failed to decode onboarding_questions.json: \(error)")
        }
    }
}
