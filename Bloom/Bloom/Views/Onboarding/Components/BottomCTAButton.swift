import SwiftUI

struct BottomCTAButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(enabled ? Color.black.opacity(0.88) : BloomTheme.textSecondary)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(enabled ? Color.black.opacity(0.88) : BloomTheme.textSecondary)
            }
            .padding(.horizontal, 22)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: BloomTheme.buttonCorner, style: .continuous)
                    .fill(enabled ? AnyShapeStyle(BloomTheme.buttonGradient) : AnyShapeStyle(BloomTheme.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: BloomTheme.buttonCorner, style: .continuous)
                            .stroke(enabled ? Color.white.opacity(0.08) : BloomTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1.0 : 0.72)
    }
}
