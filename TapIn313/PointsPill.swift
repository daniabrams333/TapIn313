import SwiftUI

/// Yellow pill that shows points. Accent Yellow with Rise Blue text, as the brand guide asks.
struct PointsPill: View {
    let points: Int
    var suffix: String?
    /// "+" for points earned, "−" for points spent.
    var sign = "+"

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .accessibilityHidden(true)
            Text("\(sign)\(points)")
            if let suffix {
                Text(suffix)
            }
        }
        .font(.subheadline.weight(.bold))
        .foregroundStyle(Theme.onHighlight)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Theme.highlight, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(points) points" + (suffix.map { " \($0)" } ?? ""))
    }
}
