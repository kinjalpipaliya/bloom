import SwiftUI

struct PatternsSelectionView: View {
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

                        Text("Which inner patterns have been getting in your way?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Awareness makes it easier to reshape what keeps repeating.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.patterns) { item in
                                SelectionTile(
                                    emoji: item.emoji,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    isSelected: viewModel.isPatternSelected(item)
                                ) {
                                    viewModel.togglePattern(item)
                                }
                            }
                        }

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, BloomTheme.pagePadding)
                }
            }

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
                    enabled: viewModel.canContinueFromPatterns
                ) {
                    viewModel.goNext()
                }
                .padding(.horizontal, BloomTheme.pagePadding)
                .padding(.bottom, 18)
                .background(BloomTheme.background)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
