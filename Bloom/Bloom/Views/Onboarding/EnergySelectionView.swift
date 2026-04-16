import SwiftUI

struct EnergySelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

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

                        Text("How has your energy been showing up lately?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Choose the one that feels most true for this phase of life.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        VStack(spacing: 14) {
                            ForEach(viewModel.energy) { item in
                                SelectionTile(
                                    emoji: item.emoji,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    isSelected: viewModel.isEnergySelected(item)
                                ) {
                                    viewModel.selectEnergy(item)
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
                    enabled: viewModel.canContinueFromEnergy
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
