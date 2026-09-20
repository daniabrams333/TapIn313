import SwiftUI

/// The digital gift card for one redemption. Opened right after redeeming,
/// and again from the activity list on the Profile.
struct GiftCardScreen: View {
    @Environment(AppStore.self) private var store
    let redemption: Redemption

    private var reward: Reward? { store.reward(redemption.rewardID) }
    private var merchant: Merchant? { reward.flatMap { store.merchant($0.merchantID) } }

    /// Read out letter by letter, with "dash" for the hyphens.
    private var spokenCode: String {
        redemption.code.map { $0 == "-" ? "dash" : String($0) }.joined(separator: " ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                card

                VStack(alignment: .leading, spacing: 6) {
                    Label("\(redemption.cost) points spent", systemImage: "star.fill")
                        .font(.headline)
                    Text("Redeemed \(redemption.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Your balance now: \(store.pointsBalance(for: redemption.studentID)) points")
                        .font(.subheadline)
                }

                Text("Demo code. It is not valid at any store. Merchants and rewards are made-up examples for this demo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Gift card")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let merchant {
                HStack(spacing: 12) {
                    Image(systemName: merchant.symbol)
                        .font(.title3)
                        .foregroundStyle(Theme.onSoftFill)
                        .frame(width: 44, height: 44)
                        .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(merchant.name)
                            .font(.headline)
                        Text(merchant.neighborhood)
                            .font(.subheadline)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reward?.title ?? "Reward")
                    .font(.title2.bold())
                if let detail = reward?.detail {
                    Text(detail)
                        .font(.subheadline)
                }
            }

            VStack(spacing: 6) {
                Text("Your code")
                    .font(.footnote.weight(.semibold))
                Text(redemption.code)
                    .font(.largeTitle.monospaced().bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .textSelection(.enabled)
                    .accessibilityLabel("Gift card code: \(spokenCode)")
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .foregroundStyle(Theme.onSoftFill)
            .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 12))
        }
        .foregroundStyle(Theme.onPrimary)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.primary, in: RoundedRectangle(cornerRadius: 16))
    }
}
