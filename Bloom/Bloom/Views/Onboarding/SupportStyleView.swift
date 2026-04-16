import SwiftUI

struct SupportStyleView: View {
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

                        Text("What kind of support would feel best right now?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Choose the style that feels easiest to return to consistently.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .lineSpacing(5)

                        VStack(spacing: 14) {
                            ForEach(viewModel.supportStyles) { style in
                                SelectionCard(
                                    icon: style.icon,
                                    title: style.title,
                                    subtitle: style.subtitle,
                                    isSelected: viewModel.isSupportStyleSelected(style)
                                ) {
                                    viewModel.selectSupportStyle(style)
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
                title: "See my Bloom path",
                enabled: viewModel.canContinueFromSupportStyle
            ) {
                viewModel.goNext()
            }
            .padding(.horizontal, BloomTheme.pagePadding)
            .padding(.bottom, 18)
            .background(BloomTheme.background)
        }
    }
}
