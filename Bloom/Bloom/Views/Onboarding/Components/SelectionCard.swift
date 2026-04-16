import SwiftUI

struct SelectionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? BloomTheme.cream : BloomTheme.lavender)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(isSelected ? BloomTheme.lavender.opacity(0.18) : BloomTheme.elevatedBackground)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(BloomTheme.lavender)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(BloomTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                isSelected ? BloomTheme.lavender.opacity(0.6) : BloomTheme.cardBorder,
                                lineWidth: isSelected ? 1.6 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
