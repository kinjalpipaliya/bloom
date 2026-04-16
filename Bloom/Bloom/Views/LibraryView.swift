import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BloomTheme.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 18) {
                    Text("Library")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text("Saved sessions and favorites will appear here.")
                        .font(.system(size: 16))
                        .foregroundStyle(BloomTheme.textSecondary)

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(BloomTheme.card)
                        .frame(height: 180)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "heart.text.square")
                                    .font(.system(size: 30))
                                    .foregroundStyle(BloomTheme.cream)

                                Text("Your saved sessions will live here")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(BloomTheme.textPrimary)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(BloomTheme.cardBorder, lineWidth: 1)
                        )

                    Spacer()
                }
                .padding(BloomTheme.pagePadding)
            }
            .navigationBarHidden(true)
        }
    }
}
