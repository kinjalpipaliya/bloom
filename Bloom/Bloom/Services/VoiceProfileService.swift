import Foundation
import Supabase

final class VoiceProfileService {
    static let shared = VoiceProfileService()

    private init() {}

    struct VoiceProfileUpsert: Encodable {
        let user_id: UUID
        let sample_audio_url: String
    }

    struct VoiceProfile: Decodable {
        let id: UUID
        let user_id: UUID
        let sample_audio_url: String
        let created_at: String
        let updated_at: String
    }

    func uploadVoiceSample(userId: UUID, localFileURL: URL) async throws -> String {
        let fileName = "\(userId.uuidString)-voice-sample.m4a"
        let storagePath = "samples/\(fileName)"
        let data = try Data(contentsOf: localFileURL)

        try await SupabaseManager.shared.client.storage
            .from("voice-samples")
            .upload(
                storagePath,
                data: data,
                options: FileOptions(
                    contentType: "audio/m4a",
                    upsert: true
                )
            )

        let publicURL = try SupabaseManager.shared.client.storage
            .from("voice-samples")
            .getPublicURL(path: storagePath)

        let payload = VoiceProfileUpsert(
            user_id: userId,
            sample_audio_url: publicURL.absoluteString
        )

        try await SupabaseManager.shared.client
            .from("user_voice_profiles")
            .upsert(payload)
            .execute()

        return publicURL.absoluteString
    }

    func fetchVoiceProfile(userId: UUID) async throws -> VoiceProfile? {
        let response = try await SupabaseManager.shared.client
            .from("user_voice_profiles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .limit(1)
            .execute()

        let rows = try JSONDecoder().decode([VoiceProfile].self, from: response.data)
        return rows.first
    }
}
