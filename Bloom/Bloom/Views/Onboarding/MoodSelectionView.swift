import SwiftUI

struct MoodSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackButtonView {
                        viewModel.goBack()
                    }
                    Spacer()
                }
                .padding(.horizontal, BloomTheme.pagePadding)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        Spacer().frame(height: 18)

                        Text("How have you been feeling lately?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Choose a few that feel closest to your current season.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.moods) { mood in
                                SelectionTile(
                                    emoji: mood.emoji,
                                    title: mood.title,
                                    subtitle: mood.subtitle,
                                    isSelected: viewModel.isMoodSelected(mood)
                                ) {
                                    viewModel.toggleMood(mood)
                                }
                            }
                        }

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, BloomTheme.pagePadding)
                }
            }

            bottomBar
        }
        .navigationBarBackButtonHidden(true)
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    BloomTheme.background.opacity(0.0),
                    BloomTheme.background.opacity(0.82),
                    BloomTheme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)

            BottomCTAButton(
                title: "Continue",
                enabled: viewModel.canContinueFromMood
            ) {
                viewModel.goNext()
            }
            .padding(.horizontal, BloomTheme.pagePadding)
            .padding(.bottom, 18)
            .background(BloomTheme.background)
        }
    }
}
