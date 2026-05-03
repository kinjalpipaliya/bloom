import SwiftUI

struct LibraryView: View {
    @State private var generatedSessions: [Session] = []
    @State private var savedSessionIDs: Set<UUID> = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private struct GeneratedSessionRow: Decodable {
        let id: UUID
        let title: String
        let subtitle: String?
        let script_text: String
        let audio_url: String
        let session_type: String?
        let duration_seconds: Int?
        let cover_emoji: String?
        let created_at: String?
    }

    var body: some View {
        ZStack {
            BloomTheme.background.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(BloomTheme.cream)
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Library")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        if generatedSessions.isEmpty {
                            emptyState
                        } else {
                            Text("Your generated sessions")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(BloomTheme.textPrimary)

                            ForEach(generatedSessions) { session in
                                SessionRow(
                                    session: session,
                                    isSaved: savedSessionIDs.contains(session.id)
                                ) {
                                    await toggleSave(for: session)
                                }
                            }
                        }
                    }
                    .padding(BloomTheme.pagePadding)
                }
            }
        }
        .task {
            await loadData()
        }
        .navigationBarHidden(true)
    }

    private var emptyState: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(BloomTheme.card)
            .frame(height: 180)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundStyle(BloomTheme.cream)

                    Text("No generated sessions yet")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text("Generate a personalized affirmation and it will appear here.")
                        .font(.system(size: 14))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            )
    }

    private func loadData() async {
        guard let userId = AuthManager.shared.currentUserId else {
            isLoading = false
            return
        }

        do {
            async let sessions = fetchGeneratedSessions(for: userId)
            async let savedIDs = FavoritesService.shared.fetchSavedSessionIDs(for: userId)

            generatedSessions = try await sessions
            savedSessionIDs = try await savedIDs
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func fetchGeneratedSessions(for userId: UUID) async throws -> [Session] {
        let response = try await SupabaseManager.shared.client
            .from("generated_sessions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()

        let rows = try JSONDecoder().decode([GeneratedSessionRow].self, from: response.data)

        return rows.map { row in
            Session(
                id: row.id,
                title: row.title,
                subtitle: row.subtitle,
                category: row.session_type ?? "personalized_affirmation",
                session_type: row.session_type ?? "personalized_affirmation",
                duration_seconds: row.duration_seconds ?? 60,
                cover_emoji: row.cover_emoji,
                audio_url: row.audio_url,
                script_text: row.script_text,
                is_featured: false
            )
        }
    }

    private func toggleSave(for session: Session) async {
        guard let userId = AuthManager.shared.currentUserId else { return }

        let isCurrentlySaved = savedSessionIDs.contains(session.id)

        do {
            try await FavoritesService.shared.toggleSavedSession(
                userId: userId,
                sessionId: session.id,
                isCurrentlySaved: isCurrentlySaved
            )

            if isCurrentlySaved {
                savedSessionIDs.remove(session.id)
            } else {
                savedSessionIDs.insert(session.id)
            }
        } catch {
            print("Failed to toggle save:", error)
        }
    }
}

private struct SessionRow: View {
    let session: Session
    let isSaved: Bool
    let onToggleSave: () async -> Void

    var body: some View {
        NavigationLink(destination: PlayerView(session: session)) {
            HStack(spacing: 14) {
                Text(session.cover_emoji ?? "✨")
                    .font(.system(size: 26))

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(BloomTheme.textPrimary)

                    if let subtitle = session.subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(BloomTheme.textSecondary)
                    }
                }

                Spacer()

                Button {
                    Task { await onToggleSave() }
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? BloomTheme.rose : BloomTheme.cream)
                        .font(.system(size: 18, weight: .medium))
                }
                .buttonStyle(.plain)

                Image(systemName: "play.fill")
                    .foregroundStyle(BloomTheme.cream)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(BloomTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(BloomTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
