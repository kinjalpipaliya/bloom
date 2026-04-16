import SwiftUI

struct SelectionTile: View {
    let emoji: String
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(emoji)
                    .font(.system(size: 28))

                Spacer(minLength: 0)

                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(BloomTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(
                                isSelected ? BloomTheme.lavender.opacity(0.7) : BloomTheme.cardBorder,
                                lineWidth: isSelected ? 1.6 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? BloomTheme.lavender.opacity(0.14) : .clear, radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }
}
