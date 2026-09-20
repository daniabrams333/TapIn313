import SwiftUI

/// The Tap In 313 brand mark: a tap ripple. A dot with two rings spreading out, drawn in pixels
/// to match the avatars and badges. It stands for the tap that confirms a student showed up.
/// Colors come from `Theme`. The City logo and "Rise Higher" are never used.
enum BrandArt {
    /// `y` is the dot, `w` the inner ring, `g` the outer ring.
    static let mark: [String] = [
        "................",
        ".....gggggg.....",
        "....gg....gg....",
        "...g........g...",
        "..g...wwww...g..",
        ".gg..w....w..gg.",
        ".g..w......w..g.",
        ".g..w..yy..w..g.",
        ".g..w..yy..w..g.",
        ".g..w......w..g.",
        ".gg..w....w..gg.",
        "..g...wwww...g..",
        "...g........g...",
        "....gg....gg....",
        ".....gggggg.....",
        "................",
    ]
}
