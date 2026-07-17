import SwiftUI

/// App settings: sections management, theme, biometric app lock and about.
struct SettingsView: View {
    @AppStorage("appTheme") private var appThemeRaw = AppTheme.system.rawValue
    @AppStorage(AppLockManager.enabledDefaultsKey) private var appLockEnabled = false
    @State private var showingBiometricsAlert = false

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return "\(version ?? "1.0.0") (\(build ?? "1"))"
    }

    var body: some View {
        Form {
            Section("Organization") {
                NavigationLink {
                    SectionsSettingsView()
                } label: {
                    Label("Sections", systemImage: "square.stack")
                }
            }

            Section("Appearance") {
                Picker(selection: $appThemeRaw) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme.rawValue)
                    }
                } label: {
                    Label("Theme", systemImage: "circle.lefthalf.filled")
                }
            }

            Section {
                Toggle(isOn: $appLockEnabled) {
                    Label("Require Face ID / Touch ID", systemImage: "faceid")
                }
                .onChange(of: appLockEnabled) { _, enabled in
                    if enabled && !AppLockManager.biometricsAvailable() {
                        appLockEnabled = false
                        showingBiometricsAlert = true
                    }
                }
            } header: {
                Text("Privacy")
            } footer: {
                Text("When enabled, the app locks on launch and whenever it goes to the background.")
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                LabeledContent("Author", value: "Alberto Licea")
                Text("My Wallet IDs is an offline vault for the cards in your pocket. It never connects to the internet and it is not a payment wallet: no NFC, no transactions, just your data on your device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .alert("Biometrics Unavailable", isPresented: $showingBiometricsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Set up Face ID, Touch ID or a device passcode to use the app lock.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
