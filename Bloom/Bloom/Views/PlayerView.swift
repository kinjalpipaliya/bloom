import SwiftUI

struct PlayerView: View {
    let session: Session

    @Environment(\.dismiss) private var dismiss

    @StateObject private var player = AudioPlayerService()
    @StateObject private var backgroundAudio = BackgroundAudioService.shared

    @State private var lines: [String] = []

    private var activeLineIndex: Int {
        guard !lines.isEmpty, player.duration > 0 else { return 0 }
        let progress = min(max(player.currentTime / player.duration, 0), 0.999)
        return min(Int(progress * Double(lines.count)), lines.count - 1)
    }

    private var visibleLineRange: [Int] {
        guard !lines.isEmpty else { return [] }

        let start = max(activeLineIndex - 2, 0)
        let end = min(activeLineIndex + 2, lines.count - 1)

        return Array(start...end)
    }

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 20)

                lyricsView

                Spacer(minLength: 20)

                controls
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
        .task {
            prepareLines()
            await player.loadRemoteAudio(from: session.audio_url)
            backgroundAudio.resumeIfNeeded()
        }
        .onDisappear {
            player.stop()
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(session.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .lineLimit(1)

                if let subtitle = session.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    private var lyricsView: some View {
        VStack(spacing: 22) {
            if lines.isEmpty {
                Text("No affirmation text available.")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                ForEach(visibleLineRange, id: \.self) { index in
                    Text(lines[index])
                        .font(.system(
                            size: index == activeLineIndex ? 30 : 22,
                            weight: index == activeLineIndex ? .bold : .semibold,
                            design: .rounded
                        ))
                        .foregroundStyle(index == activeLineIndex ? BloomTheme.textPrimary : BloomTheme.textSecondary.opacity(0.38))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .scaleEffect(index == activeLineIndex ? 1.02 : 0.94)
                        .blur(radius: index == activeLineIndex ? 0 : 0.2)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.55), value: activeLineIndex)
    }

    private var controls: some View {
        VStack(spacing: 18) {
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

            Button {
                player.togglePlayPause()
            } label: {
                Circle()
                    .fill(BloomTheme.buttonGradient)
                    .frame(width: 78, height: 78)
                    .overlay(
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.9))
                            .offset(x: player.isPlaying ? 0 : 3)
                    )
                    .shadow(color: BloomTheme.rose.opacity(0.18), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled((session.audio_url ?? "").isEmpty)
            .opacity((session.audio_url ?? "").isEmpty ? 0.5 : 1)
        }
    }

    private func prepareLines() {
        guard let script = session.script_text, !script.isEmpty else {
            lines = []
            return
        }

        lines = script
            .replacingOccurrences(of: "\n\n", with: "\n")
            .components(separatedBy: CharacterSet(charactersIn: ".\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                if line.hasSuffix("…") || line.hasSuffix("...") {
                    return line
                }
                return line
            }
    }

    private func timeString(_ value: Double) -> String {
        let total = Int(value)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
