import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        Group {
            if viewModel.showSplash {
                SplashView(viewModel: viewModel)
            } else {
                NavigationStack {
                    if viewModel.didFinishOnboarding {
                        Text("Main app comes next")
                            .font(.title2.bold())
                            .foregroundStyle(BloomTheme.textPrimary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(BloomTheme.background)
                    } else {
                        currentOnboardingView
                    }
                }
            }
        }
        .background(BloomTheme.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var currentOnboardingView: some View {
        switch viewModel.currentStep {
        case .intro:
            IntroChoiceView(viewModel: viewModel)
        case .mood:
            MoodSelectionView(viewModel: viewModel)
        case .intent:
            IntentSelectionView(viewModel: viewModel)
        case .supportStyle:
            SupportStyleView(viewModel: viewModel)
        case .summary:
            PersonalSummaryView(viewModel: viewModel)
        }
    }
}
