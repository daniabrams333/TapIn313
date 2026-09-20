import SwiftUI

/// A short burst of falling pixel squares in brand colors. It stops on its own after a few seconds.
/// Skip it entirely when Reduce Motion is on.
struct PixelConfetti: View {
    private struct Piece {
        let x: Double        // 0 to 1 across the screen
        let delay: Double    // seconds before it starts falling
        let duration: Double // seconds to reach the bottom
        let size: CGFloat
        let drift: Double    // sideways sway in points
        let color: Color
    }

    private static let totalDuration: Double = 5

    private let pieces: [Piece]
    @State private var start = Date()
    @State private var isFinished = false

    init() {
        let palette: [Color] = [Theme.highlight, .white, Theme.softFill, Theme.progress]
        func fraction(_ value: Double) -> Double { value - value.rounded(.down) }
        pieces = (0..<44).map { index in
            let i = Double(index)
            return Piece(
                x: fraction(i * 0.61803),
                delay: fraction(i * 0.37) * 1.1,
                duration: 2.4 + fraction(i * 0.53) * 1.6,
                size: 6 + CGFloat(Int(fraction(i * 0.29) * 3)) * 3,
                drift: (fraction(i * 0.71) - 0.5) * 70,
                color: palette[index % palette.count]
            )
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: isFinished)) { context in
            Canvas { canvas, size in
                let elapsed = context.date.timeIntervalSince(start)
                for piece in pieces {
                    let t = elapsed - piece.delay
                    guard t > 0, t < piece.duration else { continue }
                    let progress = t / piece.duration
                    let x = piece.x * size.width + piece.drift * sin(progress * 6)
                    let y = -20 + progress * (size.height + 40)
                    // Fade out over the last fifth of the fall.
                    let opacity = progress > 0.8 ? (1 - progress) / 0.2 : 1
                    let rect = CGRect(x: x, y: y, width: piece.size, height: piece.size)
                    canvas.fill(Path(rect), with: .color(piece.color.opacity(opacity)), style: FillStyle(antialiased: false))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task {
            try? await Task.sleep(for: .seconds(Self.totalDuration))
            isFinished = true
        }
    }
}
