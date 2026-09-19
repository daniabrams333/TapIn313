import SwiftUI

/// The legend for the Programs map: what each pin means, what the activity icons are,
/// and a reminder about where the data comes from.
struct MapKeyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Map key")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                KeyRow(text: "Up next: your next step on your track") {
                    MapPin(symbol: "gearshape.2.fill", count: 1, isUpNext: true, isCompact: true)
                }
                KeyRow(text: "A program. Tap it for details.") {
                    MapPin(symbol: "paintpalette.fill", count: 1, isUpNext: false, isCompact: true)
                }
                KeyRow(text: "A site with more than one program. The number is how many.") {
                    MapPin(symbol: "figure.run", count: 2, isUpNext: false, isCompact: true)
                }
                KeyRow(text: "You are here, if you allow location.") {
                    Circle()
                        .fill(Color(.systemBlue))
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                        .frame(width: 18, height: 18)
                }

                Divider()

                Text("Activity icons")
                    .font(.subheadline.weight(.semibold))
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 8) {
                    ForEach(ProgramCategory.allCases) { category in
                        Label(category.title, systemImage: category.symbol)
                            .font(.footnote)
                    }
                }

                Text("Site and activity names come from GOAL Line Detroit. Pin spots are approximate, and schedules are samples for this demo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(maxWidth: 320, maxHeight: 380)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 6)
    }
}

private struct KeyRow<Icon: View>: View {
    let text: String
    @ViewBuilder let icon: Icon

    var body: some View {
        HStack(spacing: 12) {
            icon
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)
            Text(text)
                .font(.footnote)
        }
        .accessibilityElement(children: .combine)
    }
}
