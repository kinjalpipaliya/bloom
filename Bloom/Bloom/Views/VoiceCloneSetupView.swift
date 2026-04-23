import SwiftUI

struct VoiceCloneSetupView: View {
    @StateObject private var recorder = VoiceRecordingService()

    @State private var isUploading = false
    @State private var uploadMessage: String?
    @State private var uploadedSampleURL: String?
    @State private var isReplacingVoice = false

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    heroCard
                    instructionsCard

                    if shouldShowRecorderCard {
                        recorderCard
                    }

                    if shouldShowSuccessCard {
                        successCard
                    }

                    if let message = uploadMessage, !message.isEmpty {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundStyle(message.lowercased().contains("failed") ? .red.opacity(0.9) : BloomTheme.cream)
                    }

                    if let errorMessage = recorder.errorMessage, !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.9))
                    }

                    Spacer(minLength: 24)
                }
                .padding(24)
            }
        }
        .navigationTitle("My Voice")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await recorder.requestPermission()
            await loadExistingVoiceProfile()
        }
    }

    private var shouldShowRecorderCard: Bool {
        uploadedSampleURL == nil || isReplacingVoice
    }

    private var shouldShowSuccessCard: Bool {
        uploadedSampleURL != nil && !isReplacingVoice
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Circle()
                .fill(BloomTheme.cream.opacity(0.12))
                .frame(width: 58, height: 58)
                .overlay(
                    Image(systemName: "waveform.badge.mic")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(BloomTheme.cream)
                )

            Text("Create your Bloom voice")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            Text("Record a short sample in your natural voice. Bloom will use it later to create more personal affirmation audio.")
                .font(.system(size: 16))
                .foregroundStyle(BloomTheme.textSecondary)
                .lineSpacing(4)
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

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to record")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            instructionRow("Find a quiet room.")
            instructionRow("Speak naturally for 30 to 60 seconds.")
            instructionRow("Use one clear pace and tone.")
            instructionRow("Save the sample once you're happy with it.")
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

    private var recorderCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(uploadedSampleURL == nil ? "Voice sample" : "Record a new sample")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)

                Spacer()

                if recorder.recordingURL != nil {
                    Text(timeString(recorder.recordingDuration))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(BloomTheme.elevatedBackground)
                        )
                }
            }

            Text(uploadedSampleURL == nil
                 ? "Record a sample, preview it, then save it to Bloom."
                 : "Record a better sample and replace the one currently saved.")
                .font(.system(size: 14))
                .foregroundStyle(BloomTheme.textSecondary)
                .lineSpacing(4)

            HStack(spacing: 12) {
                Button {
                    if recorder.isRecording {
                        recorder.stopRecording()
                    } else {
                        recorder.startRecording()
                    }
                } label: {
                    HStack {
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                        Text(recorder.isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.88))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(BloomTheme.buttonGradient)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!recorder.hasPermission || isUploading)

                Button {
                    recorder.togglePlayback()
                } label: {
                    HStack {
                        Image(systemName: recorder.isPlaying ? "pause.fill" : "play.fill")
                        Text(recorder.isPlaying ? "Pause" : "Preview")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(BloomTheme.elevatedBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(recorder.recordingURL == nil || isUploading)
            }

            Button {
                Task {
                    await uploadSample()
                }
            } label: {
                HStack {
                    if isUploading {
                        ProgressView()
                            .tint(Color.black.opacity(0.88))
                    }

                    Text(buttonTitle)
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.88))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(BloomTheme.buttonGradient)
                )
            }
            .buttonStyle(.plain)
            .disabled(recorder.recordingURL == nil || isUploading)

            HStack(spacing: 16) {
                if recorder.recordingURL != nil {
                    Button {
                        recorder.deleteRecording()
                        uploadMessage = nil
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete local sample")
                        }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.red.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    .disabled(isUploading)
                }

                if uploadedSampleURL != nil && isReplacingVoice {
                    Button {
                        isReplacingVoice = false
                        recorder.deleteRecording()
                        uploadMessage = nil
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(BloomTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(isUploading)
                }
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

    private var successCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.green)
                            .font(.system(size: 20, weight: .bold))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Voice saved")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text("Your Bloom voice is ready")
                        .font(.system(size: 13))
                        .foregroundStyle(BloomTheme.textSecondary)
                }
            }

            Text("Bloom can now use this saved sample later when generating more personal affirmation audio for you.")
                .font(.system(size: 14))
                .foregroundStyle(BloomTheme.textSecondary)
                .lineSpacing(4)

            Button {
                isReplacingVoice = true
                uploadMessage = nil
                recorder.deleteRecording()
            } label: {
                Text("Replace voice sample")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(BloomTheme.elevatedBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
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

    private var buttonTitle: String {
        if isUploading {
            return "Saving..."
        }
        return uploadedSampleURL == nil ? "Save Voice Sample" : "Replace Saved Voice"
    }

    private func loadExistingVoiceProfile() async {
        guard let userId = AuthManager.shared.currentUserId else { return }

        do {
            if let profile = try await VoiceProfileService.shared.fetchVoiceProfile(userId: userId) {
                uploadedSampleURL = profile.sample_audio_url
            }
        } catch {
            uploadMessage = "Failed to load existing voice profile."
        }
    }

    private func uploadSample() async {
        guard let userId = AuthManager.shared.currentUserId else {
            uploadMessage = "You must be signed in."
            return
        }

        guard let localURL = recorder.recordingURL else {
            uploadMessage = "Record a sample first."
            return
        }

        isUploading = true
        uploadMessage = nil

        do {
            let publicURL = try await VoiceProfileService.shared.uploadVoiceSample(
                userId: userId,
                localFileURL: localURL
            )
            uploadedSampleURL = publicURL
            isReplacingVoice = false
            recorder.deleteRecording()
            uploadMessage = "Your Bloom voice is ready ✨"
        } catch {
            uploadMessage = "Failed to upload voice sample: \(error.localizedDescription)"
        }

        isUploading = false
    }

    private func instructionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BloomTheme.cream)
                .font(.system(size: 16))

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(BloomTheme.textSecondary)
        }
    }

    private func timeString(_ value: Double) -> String {
        let total = Int(value)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
