import Foundation
import AVFoundation

@MainActor
final class AudioPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var duration: Double = 0
    @Published var currentTime: Double = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func loadRemoteAudio(from urlString: String?) async {
        stop()

        BackgroundAudioService.shared.configureSession()

        guard
            let urlString,
            let url = URL(string: urlString)
        else {
            duration = 0
            currentTime = 0
            isPlaying = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()

            self.player = audioPlayer
            self.duration = audioPlayer.duration
            self.currentTime = 0
            self.isPlaying = false
        } catch {
            print("Failed to load audio: \(error)")
            duration = 0
            currentTime = 0
            isPlaying = false
        }
    }

    func togglePlayPause() {
        guard let player else { return }

        if player.isPlaying {
            player.pause()
            stopTimer()
            isPlaying = false
            BackgroundAudioService.shared.pause()
        } else {
            BackgroundAudioService.shared.resumeIfNeeded()
            player.play()
            startTimer()
            isPlaying = true
        }
    }

    func seek(to value: Double) {
        guard let player else { return }
        player.currentTime = value
        currentTime = value
    }

    func stop() {
        player?.stop()
        player = nil
        stopTimer()
        isPlaying = false
        duration = 0
        currentTime = 0
        BackgroundAudioService.shared.stop()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        isPlaying = false
        currentTime = duration
        BackgroundAudioService.shared.pause()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            self.currentTime = player.currentTime
            self.duration = player.duration
            self.isPlaying = player.isPlaying
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
