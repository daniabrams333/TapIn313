import SwiftUI

/// A student's pixel-art avatar: a person with a hairstyle, skin tone, and shirt picked from
/// `Student.colorIndex`. No photos: students are minors, so avatars are drawn characters only.
struct AvatarView: View {
    let student: Student
    @ScaledMetric private var side: CGFloat

    init(student: Student, size: CGFloat = 96) {
        self.student = student
        _side = ScaledMetric(wrappedValue: size, relativeTo: .title)
    }

    var body: some View {
        let look = Theme.avatarLook(student.colorIndex)
        let art = PixelArt.avatars[student.colorIndex % PixelArt.avatars.count]

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
        .accessibilityLabel("\(student.displayName) avatar")
    }
}
