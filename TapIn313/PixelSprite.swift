import SwiftUI

/// Draws a pixel-art grid. Each character in a row is one square pixel, colored by `colors`.
/// A character with no entry in `colors` (such as `.`) is left empty.
struct PixelSprite: View {
    let rows: [String]
    let colors: [Character: Color]

    private var gridWidth: Int { rows.map(\.count).max() ?? 1 }
    private var gridHeight: Int { max(rows.count, 1) }

    var body: some View {
        Canvas { context, size in
            // Snap each pixel to the screen's pixel grid so the edges stay sharp.
            let scale = context.environment.displayScale
            let raw = min(size.width / CGFloat(gridWidth), size.height / CGFloat(gridHeight))
            let cell = max((raw * scale).rounded(.down) / scale, 1 / scale)
            let originX = (size.width - cell * CGFloat(gridWidth)) / 2
            let originY = (size.height - cell * CGFloat(gridHeight)) / 2

            for (y, row) in rows.enumerated() {
                for (x, character) in row.enumerated() {
                    guard let color = colors[character] else { continue }
                    let rect = CGRect(
                        x: originX + CGFloat(x) * cell,
                        y: originY + CGFloat(y) * cell,
                        width: cell,
                        height: cell
                    )
                    context.fill(Path(rect), with: .color(color), style: FillStyle(antialiased: false))
                }
            }
        }
        .aspectRatio(CGFloat(gridWidth) / CGFloat(gridHeight), contentMode: .fit)
        .accessibilityHidden(true)
    }
}
