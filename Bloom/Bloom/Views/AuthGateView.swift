import SwiftUI
import AuthenticationServices

struct AuthGateView: View {
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    Circle()
                        .fill(BloomTheme.cream.opacity(0.12))
                        .frame(width: 88, height: 88)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(BloomTheme.cream)
                        )

                    Text("Sign in to Bloom")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text("Save your progress and keep your Bloom experience personal to you.")
                        .font(.system(size: 16))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 14) {
                    SignInWithAppleButton(
                        .continue,
                        onRequest: { request in
                            authManager.prepareAppleRequest(request)
                        },
                        onCompletion: { result in
                            Task {
                                await authManager.handleAppleCompletion(result)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .disabled(authManager.isLoading)

                    if authManager.isLoading {
                        ProgressView()
                            .tint(BloomTheme.cream)
                    }

                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}
