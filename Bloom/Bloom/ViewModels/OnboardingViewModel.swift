import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var showSplash: Bool = true
    @Published var didFinishOnboarding: Bool = false
    @Published var currentStep: BloomOnboardingStep = .intro

    @Published var selectedMoodIDs: Set<String> = []
    @Published var selectedIntentIDs: Set<String> = []
    @Published var selectedSupportStyleID: String?

    let content: BloomOnboardingContent

    var moods: [SelectionItem] { content.moods }
    var intentions: [SelectionItem] { content.intentions }
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
            currentStep = .supportStyle
        case .supportStyle:
            currentStep = .summary
        case .summary:
            didFinishOnboarding = true
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
        case .supportStyle:
            currentStep = .intent
        case .summary:
            currentStep = .supportStyle
        }
    }

    func finish() {
        didFinishOnboarding = true
    }

    func toggleMood(_ item: SelectionItem) {
        if selectedMoodIDs.contains(item.id) {
            selectedMoodIDs.remove(item.id)
        } else {
            selectedMoodIDs.insert(item.id)
        }
    }

    func toggleIntent(_ item: SelectionItem) {
        if selectedIntentIDs.contains(item.id) {
            selectedIntentIDs.remove(item.id)
        } else {
            selectedIntentIDs.insert(item.id)
        }
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

    func isSupportStyleSelected(_ item: SupportStyleItem) -> Bool {
        selectedSupportStyleID == item.id
    }

    var canContinueFromMood: Bool {
        !selectedMoodIDs.isEmpty
    }

    var canContinueFromIntent: Bool {
        !selectedIntentIDs.isEmpty
    }

    var canContinueFromSupportStyle: Bool {
        selectedSupportStyleID != nil
    }

    var selectedMoodTitles: [String] {
        moods.filter { selectedMoodIDs.contains($0.id) }.map(\.title)
    }

    var selectedIntentTitles: [String] {
        intentions.filter { selectedIntentIDs.contains($0.id) }.map(\.title)
    }

    var selectedSupportStyleTitle: String {
        supportStyles.first(where: { $0.id == selectedSupportStyleID })?.title ?? "gentle daily support"
    }

    var summaryHeadline: String {
        let moodText = naturalList(from: selectedMoodTitles)
        let intentText = naturalList(from: selectedIntentTitles)

        if moodText.isEmpty && intentText.isEmpty {
            return "Bloom will create a softer, more personal experience for you."
        } else if moodText.isEmpty {
            return "You’re looking for more \(intentText.lowercased())."
        } else if intentText.isEmpty {
            return "You’ve been feeling \(moodText.lowercased())."
        } else {
            return "You’ve been feeling \(moodText.lowercased()), and you’re ready for more \(intentText.lowercased())."
        }
    }

    var summaryBody: String {
        "Bloom can start with \(selectedSupportStyleTitle.lowercased()), so your experience feels supportive, calming, and personal from the beginning."
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
