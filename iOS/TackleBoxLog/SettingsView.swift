import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("tackleboxlog.notifEnabled") private var notifEnabled = true
    @AppStorage("tackleboxlog.showNotes") private var showNotes = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $notifEnabled)
                        .accessibilityIdentifier("notifToggle")
                    Toggle("Show Notes on List", isOn: $showNotes)
                        .accessibilityIdentifier("showNotesToggle")
                }
                Section("Pro") {
                    if purchases.isPurchased {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundColor(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {}
                            .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/tackleboxlog-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/tackleboxlog-app/terms.html")!)
                    Text("Version 1.0")
                        .foregroundColor(Theme.textMuted)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
