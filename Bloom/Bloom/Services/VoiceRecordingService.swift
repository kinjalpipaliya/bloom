import Foundation
import AVFoundation

@MainActor
final class VoiceRecordingService: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var hasPermission = false
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingURL: URL?
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var meterTimer: Timer?

    override init() {
        super.init()
        recordingURL = VoiceSampleStore.shared.loadLocalSampleURL()
    }

    func requestPermission() async {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasPermission = granted
                    if !granted {
                        self?.errorMessage = "Microphone permission is required to record your voice sample."
                    }
                    continuation.resume()
                }
            }
        }
    }

    func startRecording() {
        errorMessage = nil
        stopPlayback()

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            let url = makeRecordingURL()
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            recorder.record()

            self.recorder = recorder
            self.recordingURL = url
            self.recordingDuration = 0
            self.isRecording = true

            startTimer()
        } catch {
            errorMessage = "Could not start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        stopTimer()

        if let url = recordingURL {
            VoiceSampleStore.shared.saveLocalSampleURL(url)
        }
    }

    func togglePlayback() {
        guard let recordingURL else {
            errorMessage = "Record a sample first."
            return
        }

        if isPlaying {
            stopPlayback()
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default
            )
            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: recordingURL)
            player.delegate = self
            player.prepareToPlay()
            player.play()

            self.player = player
            self.isPlaying = true
        } catch {
            errorMessage = "Could not play recording: \(error.localizedDescription)"
        }
    }

    func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func deleteRecording() {
        stopRecording()
        stopPlayback()

        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }

        recordingURL = nil
        recordingDuration = 0
        VoiceSampleStore.shared.clear()
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        stopTimer()
        if !flag {
            errorMessage = "Recording did not finish correctly."
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }

    private func startTimer() {
        stopTimer()
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.recorder else { return }
            self.recordingDuration = recorder.currentTime
        }
    }

    private func stopTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func makeRecordingURL() -> URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent("voice_sample.m4a")
    }
}
