import SwiftUI

struct IntentSelectionView: View {
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

                        Text("What are you hoping to grow more of?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Pick the feelings or qualities you want Bloom to gently support.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.intentions) { item in
                                SelectionTile(
                                    emoji: item.emoji,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    isSelected: viewModel.isIntentSelected(item)
                                ) {
                                    viewModel.toggleIntent(item)
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
                enabled: viewModel.canContinueFromIntent
            ) {
                viewModel.goNext()
            }
            .padding(.horizontal, BloomTheme.pagePadding)
            .padding(.bottom, 18)
            .background(BloomTheme.background)
        }
    }
}
