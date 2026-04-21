import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var showSplash: Bool = true
    @Published var didFinishOnboarding: Bool = false
    @Published var currentStep: BloomOnboardingStep = .intro

    @Published var selectedMoodIDs: Set<String> = []
    @Published var selectedIntentIDs: Set<String> = []
    @Published var selectedBlockerIDs: Set<String> = []
    @Published var selectedPatternIDs: Set<String> = []
    @Published var selectedEnergyID: String?
    @Published var selectedReactionID: String?
    @Published var selectedSupportStyleID: String?

    @Published var isSaving = false
    @Published var saveErrorMessage: String?

    let content: BloomOnboardingContent

    var moods: [SelectionItem] { content.moods }
    var intentions: [SelectionItem] { content.intentions }
    var blockers: [SelectionItem] { content.blockers }
    var patterns: [SelectionItem] { content.patterns }
    var energy: [SelectionItem] { content.energy }
    var reaction: [SelectionItem] { content.reaction }
    var supportStyles: [SupportStyleItem] { content.supportStyles }

    init(content: BloomOnboardingContent = OnboardingDataLoader.load()) {
        self.content = content

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            withAnimation(.easeInOut(duration: 0.35)) {
                self?.showSplash = false
            }
        }
    }

    func goToNextFromIntro() {
        currentStep = .mood
    }

    func goNext() {
        switch currentStep {
        case .intro:
            currentStep = .mood
        case .mood:
            currentStep = .intent
        case .intent:
            currentStep = .blockers
        case .blockers:
            currentStep = .patterns
        case .patterns:
            currentStep = .energy
        case .energy:
            currentStep = .reaction
        case .reaction:
            currentStep = .supportStyle
        case .supportStyle:
            currentStep = .summary
        case .summary:
            finish()
        }
    }

    func goBack() {
        switch currentStep {
        case .intro:
            break
        case .mood:
            currentStep = .intro
        case .intent:
            currentStep = .mood
        case .blockers:
            currentStep = .intent
        case .patterns:
            currentStep = .blockers
        case .energy:
            currentStep = .patterns
        case .reaction:
            currentStep = .energy
        case .supportStyle:
            currentStep = .reaction
        case .summary:
            currentStep = .supportStyle
        }
    }

    func finish() {
        didFinishOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func toggleMood(_ item: SelectionItem) {
        toggle(item.id, in: &selectedMoodIDs)
    }

    func toggleIntent(_ item: SelectionItem) {
        toggle(item.id, in: &selectedIntentIDs)
    }

    func toggleBlocker(_ item: SelectionItem) {
        toggle(item.id, in: &selectedBlockerIDs)
    }

    func togglePattern(_ item: SelectionItem) {
        toggle(item.id, in: &selectedPatternIDs)
    }

    func selectEnergy(_ item: SelectionItem) {
        selectedEnergyID = item.id
    }

    func selectReaction(_ item: SelectionItem) {
        selectedReactionID = item.id
    }

    func selectSupportStyle(_ item: SupportStyleItem) {
        selectedSupportStyleID = item.id
    }

    func isMoodSelected(_ item: SelectionItem) -> Bool {
        selectedMoodIDs.contains(item.id)
    }

    func isIntentSelected(_ item: SelectionItem) -> Bool {
        selectedIntentIDs.contains(item.id)
    }

    func isBlockerSelected(_ item: SelectionItem) -> Bool {
        selectedBlockerIDs.contains(item.id)
    }

    func isPatternSelected(_ item: SelectionItem) -> Bool {
        selectedPatternIDs.contains(item.id)
    }

    func isEnergySelected(_ item: SelectionItem) -> Bool {
        selectedEnergyID == item.id
    }

    func isReactionSelected(_ item: SelectionItem) -> Bool {
        selectedReactionID == item.id
    }

    func isSupportStyleSelected(_ item: SupportStyleItem) -> Bool {
        selectedSupportStyleID == item.id
    }

    var canContinueFromMood: Bool { !selectedMoodIDs.isEmpty }
    var canContinueFromIntent: Bool { !selectedIntentIDs.isEmpty }
    var canContinueFromBlockers: Bool { !selectedBlockerIDs.isEmpty }
    var canContinueFromPatterns: Bool { !selectedPatternIDs.isEmpty }
    var canContinueFromEnergy: Bool { selectedEnergyID != nil }
    var canContinueFromReaction: Bool { selectedReactionID != nil }
    var canContinueFromSupportStyle: Bool { selectedSupportStyleID != nil }

    var selectedMoodTitles: [String] {
        moods.filter { selectedMoodIDs.contains($0.id) }.map(\.title)
    }

    var selectedIntentTitles: [String] {
        intentions.filter { selectedIntentIDs.contains($0.id) }.map(\.title)
    }

    var selectedBlockerTitles: [String] {
        blockers.filter { selectedBlockerIDs.contains($0.id) }.map(\.title)
    }

    var selectedPatternTitles: [String] {
        patterns.filter { selectedPatternIDs.contains($0.id) }.map(\.title)
    }

    var selectedEnergyTitle: String {
        energy.first(where: { $0.id == selectedEnergyID })?.title ?? ""
    }

    var selectedReactionTitle: String {
        reaction.first(where: { $0.id == selectedReactionID })?.title ?? ""
    }

    var selectedSupportStyleTitle: String {
        supportStyles.first(where: { $0.id == selectedSupportStyleID })?.title ?? ""
    }

    var summaryHeadline: String {
        let moodText = naturalList(from: selectedMoodTitles)
        let intentText = naturalList(from: selectedIntentTitles)

        if moodText.isEmpty && intentText.isEmpty {
            return "Bloom will shape a more personal experience for you."
        } else if moodText.isEmpty {
            return "You’re ready for more \(intentText.lowercased())."
        } else if intentText.isEmpty {
            return "You’ve been feeling \(moodText.lowercased())."
        } else {
            return "You’ve been feeling \(moodText.lowercased()), and you’re ready for more \(intentText.lowercased())."
        }
    }

    var summaryBody: String {
        "Bloom will begin with \(selectedSupportStyleTitle.lowercased()), shaped around how your energy has been feeling and how deeply things tend to stay with you."
    }

    func saveOnboardingIfPossible() async {
        guard let userId = AuthManager.shared.currentUserId else { return }

        isSaving = true
        saveErrorMessage = nil

        do {
            try await OnboardingService.shared.saveOnboarding(
                userId: userId,
                moods: selectedMoodTitles,
                intentions: selectedIntentTitles,
                blockers: selectedBlockerTitles,
                patterns: selectedPatternTitles,
                energy: selectedEnergyTitle,
                reaction: selectedReactionTitle,
                supportStyle: selectedSupportStyleTitle
            )
        } catch {
            saveErrorMessage = error.localizedDescription
            print("Failed to save onboarding: \(error)")
        }

        isSaving = false
    }

    private func toggle(_ id: String, in set: inout Set<String>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }

    private func naturalList(from items: [String]) -> String {
        switch items.count {
        case 0:
            return ""
        case 1:
            return items[0]
        case 2:
            return "\(items[0]) and \(items[1])"
        default:
            let allButLast = items.dropLast().joined(separator: ", ")
            return "\(allButLast), and \(items.last!)"
        }
    }
}
