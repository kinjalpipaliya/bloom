import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    Circle()
                        .fill(BloomTheme.lavender.opacity(0.18))
                        .frame(width: 170, height: 170)
                        .blur(radius: 30)

                    Circle()
                        .fill(BloomTheme.rose.opacity(0.14))
                        .frame(width: 130, height: 130)
                        .blur(radius: 20)

                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(BloomTheme.elevatedBackground)
                        .frame(width: 110, height: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(BloomTheme.cardBorder, lineWidth: 1)
                        )

                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(BloomTheme.cream)
                }

                Spacer()

                Text("Bloom")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .padding(.bottom, 54)
            }
        }
    }
}
