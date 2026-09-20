import SwiftUI

/// "Spend 80 points?" Nothing is deducted until the student confirms.
struct RedeemConfirmSheet: View {
    @Environment(\.dismiss) private var dismiss

    let reward: Reward
    let merchant: Merchant?
    let balance: Int
    let onConfirm: () -> Void

    var body: some View {
        // Scrolls, and can grow to full height, so the buttons stay reachable at large text sizes.
        ScrollView {
            content
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Spend \(reward.cost) points?")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(reward.title)
                    .font(.headline)
                if let merchant {
                    Text("\(merchant.name) · \(merchant.neighborhood)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                row("You have", "\(balance) points")
                row("This costs", "−\(reward.cost) points")
                Divider()
                row("You will have", "\(balance - reward.cost) points", bold: true)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("You have \(balance) points. This costs \(reward.cost). You will have \(balance - reward.cost) points.")

            VStack(spacing: 8) {
                Button(action: onConfirm) {
                    Text("Confirm and get my code")
                        .font(.headline)
                        .foregroundStyle(Theme.onPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Theme.primary, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button("Cancel") { dismiss() }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .padding(20)
    }

    private func row(_ title: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .font(bold ? .headline : .body)
    }
}
