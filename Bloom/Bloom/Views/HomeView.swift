import SwiftUI

struct HomeView: View {
    @State private var featuredSessions: [Session] = []
    @State private var allSessions: [Session] = []
    @State private var recommendedSessions: [Session] = []
    @State private var onboardingResponse: OnboardingResponse?
    @State private var savedSessionIDs: Set<UUID> = []

    @State private var isLoading = true
    @State private var errorMessage: String?

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
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        heroCard

                        if !recommendedSessions.isEmpty {
                            recommendedSection
                        }

                        featuredSection
                        allSessionsSection

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .task {
            await loadData()
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bloom")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(BloomTheme.rose)

            Text("Welcome back")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Circle()
                .fill(BloomTheme.cream.opacity(0.14))
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(BloomTheme.cream)
                )

            Text(heroTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text(heroSubtitle)
                .font(.system(size: 15))
                .foregroundStyle(BloomTheme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if let firstSession = recommendedSessions.first ?? featuredSessions.first ?? allSessions.first {
                NavigationLink(destination: PlayerView(session: firstSession)) {
                    HStack {
                        Text("Start Session")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.88))

                        Spacer()

                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.black.opacity(0.88))
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(BloomTheme.buttonGradient)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BloomTheme.elevatedBackground, BloomTheme.card],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recommended for you")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            ForEach(recommendedSessions) { session in
                SessionRow(
                    session: session,
                    isSaved: savedSessionIDs.contains(session.id),
                    onToggleSave: {
                        await toggleSave(for: session)
                    }
                )
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Featured")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            ForEach(featuredSessions) { session in
                SessionRow(
                    session: session,
                    isSaved: savedSessionIDs.contains(session.id),
                    onToggleSave: {
                        await toggleSave(for: session)
                    }
                )
            }
        }
    }

    private var allSessionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("All sessions")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            ForEach(allSessions) { session in
                SessionRow(
                    session: session,
                    isSaved: savedSessionIDs.contains(session.id),
                    onToggleSave: {
                        await toggleSave(for: session)
                    }
                )
            }
        }
    }

    private var heroTitle: String {
        guard let response = onboardingResponse else {
            return "Your daily calm starts with one small pause."
        }

        let firstIntent = response.intentions.first ?? "balance"
        let firstMood = response.moods.first ?? "a lot"

        if firstIntent.lowercased().contains("peace") {
            return "A softer space for calm and clarity."
        }

        if firstIntent.lowercased().contains("confidence") || firstIntent.lowercased().contains("self-worth") {
            return "Sessions to help you return to self-trust."
        }

        if firstIntent.lowercased().contains("better rest") {
            return "Let your mind soften before rest."
        }

        return "Support for when you've been feeling \(firstMood.lowercased())."
    }

    private var heroSubtitle: String {
        guard let response = onboardingResponse else {
            return "Take a few minutes to reset your thoughts and return to yourself."
        }

        let intentText = response.intentions.prefix(2).joined(separator: " and ").lowercased()
        let supportStyle = (response.support_style ?? "gentle daily support").lowercased()

        if !intentText.isEmpty {
            return "Bloom is prioritizing \(intentText) through \(supportStyle) that fits how you’ve been feeling."
        }

        return "Bloom is shaping a calmer experience around the support style you chose."
    }

    private func loadData() async {
        do {
            async let featured = SessionService.shared.fetchFeaturedSessions()
            async let all = SessionService.shared.fetchAllSessions()

            let featuredResult = try await featured
            let allResult = try await all

            featuredSessions = featuredResult
            allSessions = allResult

            if let userId = AuthManager.shared.currentUserId {
                async let latestOnboarding = ProfileService.shared.fetchLatestOnboardingResponse(for: userId)
                async let savedIDs = FavoritesService.shared.fetchSavedSessionIDs(for: userId)

                onboardingResponse = try await latestOnboarding
                savedSessionIDs = try await savedIDs
                recommendedSessions = buildRecommendations(from: allResult, onboarding: onboardingResponse)
            } else {
                recommendedSessions = Array(allResult.prefix(3))
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
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
            print("Failed to toggle save: \(error)")
        }
    }

    private func buildRecommendations(from sessions: [Session], onboarding: OnboardingResponse?) -> [Session] {
        guard let onboarding else {
            return Array(sessions.prefix(3))
        }

        let preferenceKeywords = (onboarding.intentions + onboarding.moods + onboarding.blockers)
            .map { $0.lowercased() }

        let scored = sessions.map { session -> (Session, Int) in
            let title = session.title.lowercased()
            let subtitle = (session.subtitle ?? "").lowercased()
            let category = session.category.lowercased()

            var score = 0

            for keyword in preferenceKeywords {
                if keyword.contains("peace") || keyword.contains("calm") {
                    if title.contains("calm") || category.contains("peace") || subtitle.contains("quiet") {
                        score += 3
                    }
                }

                if keyword.contains("confidence") || keyword.contains("self-worth") || keyword.contains("doubting") {
                    if title.contains("confidence") || category.contains("confidence") || subtitle.contains("self-trust") {
                        score += 3
                    }
                }

                if keyword.contains("rest") || keyword.contains("sleep") || keyword.contains("drained") || keyword.contains("low energy") {
                    if title.contains("sleep") || category.contains("sleep") || subtitle.contains("rest") {
                        score += 3
                    }
                }

                if keyword.contains("clarity") || keyword.contains("overwhelmed") || keyword.contains("anxious") {
                    if title.contains("calm") || title.contains("mind") || category.contains("clarity") || subtitle.contains("mental") {
                        score += 3
                    }
                }
            }

            if session.is_featured {
                score += 1
            }

            return (session, score)
        }

        return scored
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.title < rhs.0.title
                }
                return lhs.1 > rhs.1
            }
            .map(\.0)
            .prefix(3)
            .map { $0 }
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
                    Task {
                        await onToggleSave()
                    }
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
            )
        }
        .buttonStyle(.plain)
    }
}
