import SwiftUI

struct LibraryView: View {
    @State private var savedSessionIDs: Set<UUID> = []
    @State private var allSessions: [Session] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var savedSessions: [Session] {
        allSessions.filter { savedSessionIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(BloomTheme.cream)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Something went wrong")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Library")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        if savedSessions.isEmpty {
                            emptyState
                        } else {
                            Text("Saved sessions")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(BloomTheme.textPrimary)

                            VStack(spacing: 12) {
                                ForEach(savedSessions) { session in
                                    SavedSessionRow(session: session) {
                                        await removeSave(for: session)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 24)
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
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 30))
                        .foregroundStyle(BloomTheme.cream)

                    Text("No saved sessions yet")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text("Tap the heart on any session to save it here.")
                        .font(.system(size: 14))
                        .foregroundStyle(BloomTheme.textSecondary)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
            )
    }

    private func loadData() async {
        guard let userId = AuthManager.shared.currentUserId else {
            isLoading = false
            return
        }

        do {
            async let sessions = SessionService.shared.fetchAllSessions()
            async let savedIDs = FavoritesService.shared.fetchSavedSessionIDs(for: userId)

            allSessions = try await sessions
            savedSessionIDs = try await savedIDs
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func removeSave(for session: Session) async {
        guard let userId = AuthManager.shared.currentUserId else { return }

        do {
            try await FavoritesService.shared.removeSavedSession(
                userId: userId,
                sessionId: session.id
            )

            savedSessionIDs.remove(session.id)
        } catch {
            print("Failed to remove saved session: \(error)")
        }
    }
}

private struct SavedSessionRow: View {
    let session: Session
    let onRemove: () async -> Void

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
                    Task {
                        await onRemove()
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(BloomTheme.rose)
                        .font(.system(size: 18, weight: .medium))
                }
                .buttonStyle(.plain)
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
