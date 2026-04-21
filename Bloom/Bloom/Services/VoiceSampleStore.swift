import Foundation

final class VoiceSampleStore {
    static let shared = VoiceSampleStore()

    private let savedURLKey = "bloom.savedVoiceSampleURL"

    private init() {}

    func saveLocalSampleURL(_ url: URL?) {
        UserDefaults.standard.set(url?.absoluteString, forKey: savedURLKey)
    }

    func loadLocalSampleURL() -> URL? {
        guard let value = UserDefaults.standard.string(forKey: savedURLKey) else {
            return nil
        }
        return URL(string: value)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: savedURLKey)
    }
}
