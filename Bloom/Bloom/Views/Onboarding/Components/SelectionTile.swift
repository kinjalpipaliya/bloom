import SwiftUI

struct SelectionTile: View {
    let emoji: String
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(emoji)
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(BloomTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                isSelected ? BloomTheme.lavender.opacity(0.7) : BloomTheme.cardBorder,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? BloomTheme.lavender.opacity(0.10) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
