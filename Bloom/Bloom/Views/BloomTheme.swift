import SwiftUI

enum BloomTheme {
    static let background = Color(red: 13/255, green: 15/255, blue: 20/255)
    static let elevatedBackground = Color(red: 19/255, green: 23/255, blue: 34/255)
    static let card = Color(red: 23/255, green: 28/255, blue: 40/255)
    static let cardBorder = Color(red: 37/255, green: 43/255, blue: 57/255)

    static let textPrimary = Color(red: 247/255, green: 244/255, blue: 238/255)
    static let textSecondary = Color(red: 183/255, green: 180/255, blue: 198/255)

    static let lavender = Color(red: 185/255, green: 167/255, blue: 255/255)
    static let rose = Color(red: 242/255, green: 199/255, blue: 215/255)
    static let cream = Color(red: 244/255, green: 231/255, blue: 213/255)

    static let buttonGradient = LinearGradient(
        colors: [cream, rose],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let pagePadding: CGFloat = 24
    static let cardCorner: CGFloat = 28
    static let buttonCorner: CGFloat = 24
}
