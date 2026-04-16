import Foundation
import AuthenticationServices
import CryptoKit
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentNonce: String?

    private init() {}

    func restoreSession() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            isAuthenticated = true
            currentUserId = session.user.id

            try await ensureProfileExists(
                userId: session.user.id,
                email: session.user.email
            )
        } catch {
            isAuthenticated = false
            currentUserId = nil
        }
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce

        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        do {
            switch result {
            case .failure(let error):
                throw error

            case .success(let authorization):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    throw NSError(
                        domain: "AuthManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential."]
                    )
                }

                guard let nonce = currentNonce else {
                    throw NSError(
                        domain: "AuthManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing login nonce."]
                    )
                }

                guard
                    let identityToken = credential.identityToken,
                    let idTokenString = String(data: identityToken, encoding: .utf8)
                else {
                    throw NSError(
                        domain: "AuthManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unable to read Apple identity token."]
                    )
                }

                let response = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .apple,
                        idToken: idTokenString,
                        nonce: nonce
                    )
                )

                let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                try await ensureProfileExists(
                    userId: response.user.id,
                    email: response.user.email,
                    fullName: fullName.isEmpty ? nil : fullName
                )

                isAuthenticated = true
                currentUserId = response.user.id
            }
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            currentUserId = nil
        }

        isLoading = false
    }

    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            print("Sign out failed: \(error)")
        }

        isAuthenticated = false
        currentUserId = nil
    }

    private func ensureProfileExists(userId: UUID, email: String?, fullName: String? = nil) async throws {
        struct ProfileUpsert: Encodable {
            let id: UUID
            let email: String?
            let full_name: String?
        }

        let payload = ProfileUpsert(
            id: userId,
            email: email,
            full_name: fullName
        )

        try await SupabaseManager.shared.client
            .from("profiles")
            .upsert(payload)
            .execute()
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }

            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}
