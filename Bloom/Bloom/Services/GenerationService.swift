import Foundation

final class GenerationService {
    static let shared = GenerationService()

    // Change this when you test on a real device.
    // Simulator can use 127.0.0.1. Real device should use your Mac's local IP.
    private let baseURL = "http://192.168.68.100:8000"

    private init() {}

    func generateSession(userId: UUID) async throws -> GeneratedSession {
        guard let url = URL(string: "\(baseURL)/generate-session") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["user_id": userId.uuidString]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(
                domain: "GenerationService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverMessage]
            )
        }

        return try JSONDecoder().decode(GenerateSessionResponse.self, from: data).generated_session
    }
}
