import SwiftUI

struct HomeView: View {
    let quickSessions: [QuickSession] = [
        .init(title: "Morning Reset", subtitle: "Start soft and steady", icon: "sunrise.fill"),
        .init(title: "Calm Mind", subtitle: "Quiet mental noise", icon: "moon.stars.fill"),
        .init(title: "Confidence Boost", subtitle: "Return to self-trust", icon: "sparkles"),
        .init(title: "Sleep Wind Down", subtitle: "Slow down for rest", icon: "bed.double.fill")
    ]

    let categories: [HomeCategory] = [
        .init(title: "Self-worth", emoji: "🌸"),
        .init(title: "Peace", emoji: "🤍"),
        .init(title: "Abundance", emoji: "💫"),
        .init(title: "Clarity", emoji: "🌿")
    ]

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    heroCard
                    quickSessionsSection
                    categoriesSection
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bloom")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(BloomTheme.rose)

            Text("Welcome back")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            Text("Choose a session that matches what you need today.")
                .font(.system(size: 16))
                .foregroundStyle(BloomTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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

            Text("Your daily calm starts with one small pause.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("Take a few minutes to reset your thoughts and return to yourself.")
                .font(.system(size: 15))
                .foregroundStyle(BloomTheme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Button {
            } label: {
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

    private var quickSessionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick sessions")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            VStack(spacing: 12) {
                ForEach(quickSessions) { session in
                    QuickSessionRow(session: session)
                }
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(categories) { category in
                    CategoryTile(category: category)
                }
            }
        }
    }
}

struct QuickSession: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

struct HomeCategory: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
}

private struct QuickSessionRow: View {
    let session: QuickSession

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(BloomTheme.elevatedBackground)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: session.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(BloomTheme.cream)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)

                Text(session.subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(BloomTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(BloomTheme.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

private struct CategoryTile: View {
    let category: HomeCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.emoji)
                .font(.system(size: 24))

            Spacer(minLength: 0)

            Text(category.title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}
