import Foundation

enum BloomOnboardingStep: Equatable {
    case intro
    case mood
    case intent
    case supportStyle
    case summary
}

struct SelectionItem: Identifiable, Hashable, Codable, Equatable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String?
}

struct SupportStyleItem: Identifiable, Hashable, Codable, Equatable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
}

struct BloomOnboardingContent: Codable {
    let moods: [SelectionItem]
    let intentions: [SelectionItem]
    let supportStyles: [SupportStyleItem]
}
