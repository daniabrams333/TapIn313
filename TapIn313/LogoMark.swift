import SwiftUI

/// The brand mark on a Rise Blue rounded tile, like a small app icon.
struct LogoMark: View {
    @ScaledMetric private var side: CGFloat

    init(size: CGFloat = 32) {
        _side = ScaledMetric(wrappedValue: size, relativeTo: .headline)
    }

    var body: some View {
        PixelSprite(rows: BrandArt.mark, colors: ["y": Theme.highlight, "w": .white, "g": Theme.softFill])
            .padding(side * 0.07)
            .frame(width: side, height: side)
            .background(Theme.primary, in: RoundedRectangle(cornerRadius: side * 0.24))
            .accessibilityHidden(true)
    }
}

/// Mark, name, and tagline together. For the About card.
struct BrandLockup: View {
    var body: some View {
        VStack(spacing: 10) {
            LogoMark(size: 72)
            Text("Tap In 313")
                .font(.title2.bold())
            Text("Your next step starts here.")
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tap In 313. Your next step starts here.")
    }
}

// MARK: - Top bar

extension View {
    /// Puts the mark and the name at the top left of a screen. `onDark` is for the City Green staff bar.
    func brandMark(onDark: Bool = false) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    LogoMark(size: 28)
                    Text("Tap In 313")
                        .font(.headline)
                        .foregroundStyle(onDark ? Theme.onStaff : Color.primary)
                        .fixedSize()
                }
            }
        }
    }
}
