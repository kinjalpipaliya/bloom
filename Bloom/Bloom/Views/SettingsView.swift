import SwiftUI

struct SettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var backgroundAudio = BackgroundAudioService.shared

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)

                settingsRow("Notifications", "bell.fill")
                settingsRow("Playback", "play.circle.fill")
                settingsRow("About Bloom", "sparkles")

                NavigationLink(destination: VoiceCloneSetupView()) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(BloomTheme.elevatedBackground)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "waveform.badge.mic")
                                    .foregroundStyle(BloomTheme.cream)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text("My Voice")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(BloomTheme.textPrimary)

                            Text("Record your sample voice")
                                .font(.system(size: 13))
                                .foregroundStyle(BloomTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(BloomTheme.textSecondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(BloomTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)

                HStack {
                    Text("Ambient music")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { backgroundAudio.isEnabled },
                        set: { backgroundAudio.setEnabled($0) }
                    ))
                    .labelsHidden()
                    .tint(BloomTheme.cream)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(BloomTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(BloomTheme.cardBorder, lineWidth: 1)
                        )
                )

                Button {
                    Task {
                        await authManager.signOut()
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                        Spacer()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.red.opacity(0.9))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(BloomTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(BloomTheme.pagePadding)
        }
        .navigationBarHidden(true)
    }

    private func settingsRow(_ title: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(BloomTheme.elevatedBackground)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: icon)
                        .foregroundStyle(BloomTheme.cream)
                )

            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(BloomTheme.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}
