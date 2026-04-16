import SwiftUI

struct IntroChoiceView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 30)

                VStack(spacing: 22) {
                    heroCard

                    VStack(spacing: 10) {
                        Text("A space to come back to yourself")
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Bloom helps you shape a calmer inner world through reflection, guided affirmations, and soft daily support.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, BloomTheme.pagePadding)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        viewModel.goToNextFromIntro()
                    } label: {
                        HStack {
                            Text("Start gently")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(BloomTheme.textPrimary)

                            Spacer()

                            Image(systemName: "arrow.right")
                                .foregroundStyle(BloomTheme.textPrimary)
                        }
                        .padding(.horizontal, 22)
                        .frame(height: 62)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(BloomTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    BottomCTAButton(title: "Personalize Bloom") {
                        viewModel.goToNextFromIntro()
                    }
                }
                .padding(.horizontal, BloomTheme.pagePadding)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var heroCard: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        BloomTheme.elevatedBackground,
                        BloomTheme.card
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 300)
            .overlay(
                ZStack {
                    Circle()
                        .fill(BloomTheme.lavender.opacity(0.18))
                        .frame(width: 160, height: 160)
                        .blur(radius: 28)

                    Circle()
                        .fill(BloomTheme.rose.opacity(0.13))
                        .frame(width: 120, height: 120)
                        .blur(radius: 18)

                    VStack(spacing: 18) {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(BloomTheme.background.opacity(0.45))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundStyle(BloomTheme.cream)
                            )

                        Text("Midnight Bloom")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(BloomTheme.textSecondary)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
            )
    }
}
