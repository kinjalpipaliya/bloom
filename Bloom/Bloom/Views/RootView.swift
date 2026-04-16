import SwiftUI

struct RootView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var authManager = AuthManager.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var checkedSession = false

    var body: some View {
        Group {
            if onboardingViewModel.showSplash {
                SplashView(viewModel: onboardingViewModel)
            } else if !checkedSession {
                ZStack {
                    BloomTheme.background
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(BloomTheme.cream)
                }
                .task {
                    await authManager.restoreSession()
                    checkedSession = true
                }
            } else if !authManager.isAuthenticated {
                AuthGateView()
            } else if !hasCompletedOnboarding {
                NavigationStack {
                    currentOnboardingView
                }
            } else {
                MainTabView()
            }
        }
        .background(BloomTheme.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var currentOnboardingView: some View {
        switch onboardingViewModel.currentStep {
        case .intro:
            IntroChoiceView(viewModel: onboardingViewModel)
        case .mood:
            MoodSelectionView(viewModel: onboardingViewModel)
        case .intent:
            IntentSelectionView(viewModel: onboardingViewModel)
        case .blockers:
            BlockersSelectionView(viewModel: onboardingViewModel)
        case .patterns:
            PatternsSelectionView(viewModel: onboardingViewModel)
        case .energy:
            EnergySelectionView(viewModel: onboardingViewModel)
        case .reaction:
            ReactionSelectionView(viewModel: onboardingViewModel)
        case .supportStyle:
            SupportStyleView(viewModel: onboardingViewModel)
        case .summary:
            PersonalSummaryView(viewModel: onboardingViewModel)
        }
    }
}
