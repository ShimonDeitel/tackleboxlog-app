import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.accent)
                Text("Tackle Box Log Pro")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                Text("Catch-log linking lures to fish caught")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("Unlimited items too — free tier is capped at \(store.freeItemLimit).")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let product = purchases.product {
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text("Unlock for \(product.displayPrice)")
                            .font(Theme.headlineFont)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .accessibilityIdentifier("purchaseButton")
                    .padding(.horizontal)
                } else {
                    ProgressView()
                }

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywallRestoreButton")
                .foregroundColor(Theme.textMuted)

                Button("Not Now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .foregroundColor(Theme.textMuted)
            }
            .padding()
        }
    }
}
