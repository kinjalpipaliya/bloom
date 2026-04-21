import SwiftUI

struct PlayerView: View {
    let session: Session

    @StateObject private var player = AudioPlayerService()
    @StateObject private var backgroundAudio = BackgroundAudioService.shared

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topCard
                    scriptCard
                    ambientCard
                    controlsCard
                    Spacer(minLength: 24)
                }
                .padding(24)
            }
        }
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await player.loadRemoteAudio(from: session.audio_url)
            backgroundAudio.resumeIfNeeded()
        }
        .onDisappear {
            player.stop()
        }
    }

    private var topCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(session.cover_emoji ?? "✨")
                    .font(.system(size: 42))

                Spacer()

                Text(formatDuration(session.duration_seconds))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(BloomTheme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(BloomTheme.elevatedBackground)
                    )
            }

            Text(session.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = session.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(BloomTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(session.category.capitalized)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(BloomTheme.rose)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [BloomTheme.elevatedBackground, BloomTheme.card],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var scriptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session text")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            if let script = session.script_text, !script.isEmpty {
                Text(script)
                    .font(.system(size: 16))
                    .foregroundStyle(BloomTheme.textSecondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("No script text added yet for this session.")
                    .font(.system(size: 15))
                    .foregroundStyle(BloomTheme.textSecondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var ambientCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Background ambience")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { backgroundAudio.isEnabled },
                    set: { backgroundAudio.setEnabled($0) }
                ))
                .labelsHidden()
                .tint(BloomTheme.cream)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Music level")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(BloomTheme.textSecondary)

                Slider(
                    value: Binding(
                        get: { Double(backgroundAudio.volume) },
                        set: { backgroundAudio.updateVolume(Float($0)) }
                    ),
                    in: 0...0.8
                )
                .tint(BloomTheme.cream)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var controlsCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ),
                    in: 0...max(player.duration, 1)
                )
                .tint(BloomTheme.cream)

                HStack {
                    Text(timeString(player.currentTime))
                    Spacer()
                    Text(timeString(player.duration))
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(BloomTheme.textSecondary)
            }

            Button {
                player.togglePlayPause()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    Text(player.isPlaying ? "Pause" : "Play")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.88))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BloomTheme.buttonGradient)
                )
            }
            .buttonStyle(.plain)
            .disabled((session.audio_url ?? "").isEmpty)
            .opacity((session.audio_url ?? "").isEmpty ? 0.6 : 1.0)

            if (session.audio_url ?? "").isEmpty {
                Text("Add an audio_url in Supabase to play this session.")
                    .font(.system(size: 14))
                    .foregroundStyle(BloomTheme.textSecondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private func timeString(_ value: Double) -> String {
        let total = Int(value)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}
