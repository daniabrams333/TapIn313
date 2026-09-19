import SwiftUI

/// A student's pixel-art avatar: a person with a hairstyle, skin tone, and shirt picked from
/// `Student.colorIndex`. No photos: students are minors, so avatars are drawn characters only.
struct AvatarView: View {
    let displayName: String
    let colorIndex: Int
    @ScaledMetric private var side: CGFloat

    init(student: Student, size: CGFloat = 96) {
        self.init(displayName: student.displayName, colorIndex: student.colorIndex, size: size)
    }

    init(displayName: String, colorIndex: Int, size: CGFloat = 96) {
        self.displayName = displayName
        self.colorIndex = colorIndex
        _side = ScaledMetric(wrappedValue: size, relativeTo: .title)
    }

    var body: some View {
        let look = Theme.avatarLook(colorIndex)
        let art = PixelArt.avatars[colorIndex % PixelArt.avatars.count]

        ZStack {
            look.backdrop
            PixelSprite(
                rows: art,
                colors: ["h": look.hair, "e": look.hair, "s": look.skin, "d": look.shade, "t": look.shirt]
            )
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: side * 0.14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(displayName) avatar")
    }
}
