import SwiftUI

/// Rewards tab: the student's balance and a catalog grouped by local merchant.
/// Redeeming asks for a confirmation, then opens the digital gift card.
struct RewardsScreen: View {
    @Environment(AppStore.self) private var store
    @State private var rewardToRedeem: Reward?
    @State private var redeemed: Redemption?

    private var studentID: String { store.currentStudentID }
    private var balance: Int { store.pointsBalance(for: studentID) }

    /// Merchants with at least one reward, cheapest first, so what a student can afford is near the top.
    private var merchants: [Merchant] {
        func cheapest(_ merchant: Merchant) -> Int {
            store.rewards(for: merchant.id).map(\.cost).min() ?? .max
        }
        return store.merchants
            .filter { !store.rewards(for: $0.id).isEmpty }
            .sorted { cheapest($0) < cheapest($1) }
    }

    private func rewards(for merchant: Merchant) -> [Reward] {
        let all: [Reward] = store.rewards(for: merchant.id)
        return all.sorted { $0.cost < $1.cost }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(merchants) { merchant in
                    Section {
                        ForEach(rewards(for: merchant)) { reward in
                            RewardRow(reward: reward, balance: balance) {
                                rewardToRedeem = reward
                            }
                        }
                    } header: {
                        MerchantHeader(merchant: merchant)
                    }
                }

                Section {
                    Text("Merchants and rewards are made-up examples for this demo. No real businesses are involved.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                BalanceBar(balance: balance)
            }
            .navigationTitle("Rewards")
            .brandMark()
            .navigationDestination(item: $redeemed) { redemption in
                GiftCardScreen(redemption: redemption)
            }
            .sheet(item: $rewardToRedeem) { reward in
                RedeemConfirmSheet(
                    reward: reward,
                    merchant: store.merchant(reward.merchantID),
                    balance: balance,
                    onConfirm: { confirm(reward) }
                )
            }
        }
    }

    /// Closes the confirm sheet first, then redeems. That way the badge celebration a redemption
    /// can trigger never has to compete with a sheet that is still on screen.
    private func confirm(_ reward: Reward) {
        guard rewardToRedeem != nil else { return }   // ignores a second tap during the dismiss
        rewardToRedeem = nil
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            if let redemption = store.redeem(reward, studentID: studentID) {
                redeemed = redemption
            }
        }
    }
}

// MARK: - Pieces

private struct BalanceBar: View {
    let balance: Int

    var body: some View {
        HStack {
            Text("You have")
                .font(.headline)
            Spacer()
            Label("\(balance) points", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(Theme.onHighlight)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.highlight, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.bar)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("You have \(balance) points")
    }
}

private struct MerchantHeader: View {
    let merchant: Merchant

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: merchant.symbol)
                .font(.title3)
                .foregroundStyle(Theme.onPrimary)
                .frame(width: 44, height: 44)
                .background(Theme.primary, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(merchant.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(merchant.neighborhood) · \(merchant.tagline)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .textCase(nil)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct RewardRow: View {
    let reward: Reward
    let balance: Int
    let onRedeem: () -> Void

    private var canAfford: Bool { balance >= reward.cost }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(reward.title)
                        .font(.headline)
                    Spacer(minLength: 8)
                    CostPill(cost: reward.cost)
                }
                Text(reward.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(reward.title). \(reward.detail) Costs \(reward.cost) points.")

            if canAfford {
                Button(action: onRedeem) {
                    Text("Redeem")
                        .font(.headline)
                        .foregroundStyle(Theme.onHighlight)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Theme.highlight, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Redeem \(reward.title) for \(reward.cost) points")
            } else {
                // The lock and the words carry the meaning, not the color.
                Label("Need \(reward.cost - balance) more points", systemImage: "lock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 44, alignment: .leading)
                    .accessibilityLabel("Locked. You need \(reward.cost - balance) more points.")
            }
        }
        .padding(.vertical, 6)
    }
}

private struct CostPill: View {
    let cost: Int

    var body: some View {
        Label("\(cost) points", systemImage: "star.fill")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Theme.onHighlight)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.highlight, in: Capsule())
            .accessibilityHidden(true)
    }
}
