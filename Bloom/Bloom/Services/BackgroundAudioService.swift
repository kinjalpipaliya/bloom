import Foundation
import AVFoundation

@MainActor
final class BackgroundAudioService: ObservableObject {
    static let shared = BackgroundAudioService()

    @Published var isEnabled = true
    @Published var volume: Float = 0.28

    private var player: AVAudioPlayer?

    private init() {}

    func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure background audio session: \(error)")
        }
    }

    func loadAndPlayLoopIfNeeded() {
        guard isEnabled else {
            stop()
            return
        }

        if player?.isPlaying == true {
            player?.volume = volume
            return
        }

        guard let url = Bundle.main.url(forResource: "calm_loop", withExtension: "mp3") else {
            print("Missing calm_loop.mp3 in app bundle")
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = volume
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
        } catch {
            print("Failed to load background loop: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func pause() {
        player?.pause()
    }

    func resumeIfNeeded() {
        guard isEnabled else { return }
        if let player {
            player.volume = volume
            if !player.isPlaying {
                player.play()
            }
        } else {
            loadAndPlayLoopIfNeeded()
        }
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            resumeIfNeeded()
        } else {
            stop()
        }
    }

    func updateVolume(_ newValue: Float) {
        volume = newValue
        player?.volume = newValue
    }
}
