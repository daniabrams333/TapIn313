import Foundation

/// Pixel art for the unlock moments. Same keys as the badges: `#` ink, `w` white, `g` green, `.` empty.
extension PixelArt {
    /// A flag on a pole, for a completed level.
    static let unlockFlag: [String] = [
        "..#.........",
        "..#ggggg....",
        "..#gggggggg.",
        "..#ggggggggg",
        "..#gggggggg.",
        "..#ggggg....",
        "..#.........",
        "..#.........",
        "..#.........",
        "..#.........",
        ".####.......",
        "######......",
    ]

    /// A trophy, for a completed track.
    static let unlockTrophy: [String] = [
        "..########..",
        "#.#wwwwww#.#",
        "#.#wgggg.#.#",
        "#.#w.gg..#.#",
        ".##.gggg.##.",
        "..#..gg..#..",
        "...#....#...",
        "....####....",
        ".....##.....",
        ".....##.....",
        "....####....",
        "...######...",
    ]

    /// A small plus-shaped sparkle for the badge moment.
    static let unlockSparkle: [String] = [
        "..#..",
        "..#..",
        "#####",
        "..#..",
        "..#..",
    ]
}
