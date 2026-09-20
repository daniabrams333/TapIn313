import SwiftUI

/// Shown for a moment when the app opens, so the name and mark are the first thing anyone sees.
struct SplashScreen: View {
    @ScaledMetric(relativeTo: .largeTitle) private var markSize: CGFloat = 132

    var body: some View {
        ZStack {
            Theme.primary.ignoresSafeArea()

            VStack(spacing: 20) {
                PixelSprite(rows: BrandArt.mark, colors: ["y": Theme.highlight, "w": .white, "g": Theme.softFill])
                    .frame(width: markSize, height: markSize)
                Text("Tap In 313")
                    .font(.largeTitle.bold())
                Text("Your next step starts here.")
                    .font(.title3)
            }
            .foregroundStyle(Theme.onPrimary)
            .multilineTextAlignment(.center)
            .padding(24)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tap In 313. Your next step starts here.")
    }
}
