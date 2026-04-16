import SwiftUI

struct BackButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(BloomTheme.textPrimary)
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(BloomTheme.card)
                        .overlay(
                            Circle()
                                .stroke(BloomTheme.cardBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
