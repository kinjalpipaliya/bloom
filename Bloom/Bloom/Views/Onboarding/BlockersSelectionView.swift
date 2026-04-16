import SwiftUI

struct BlockersSelectionView: View {
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

                        Text("What has felt hardest to carry lately?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Choose the struggles that have been showing up most often for you.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.blockers) { item in
                                SelectionTile(
                                    emoji: item.emoji,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    isSelected: viewModel.isBlockerSelected(item)
                                ) {
                                    viewModel.toggleBlocker(item)
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
                    enabled: viewModel.canContinueFromBlockers
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
