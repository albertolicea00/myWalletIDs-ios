import SwiftData
import SwiftUI

@main
struct MyWalletIDsApp: App {
    @AppStorage("appTheme") private var appThemeRaw = AppTheme.system.rawValue
    @StateObject private var appLock = AppLockManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(AppTheme(rawValue: appThemeRaw)?.colorScheme)
                .environmentObject(appLock)
                .overlay {
                    if appLock.isLocked {
                        LockScreenView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: appLock.isLocked)
                .onAppear {
                    appLock.lockIfNeeded()
                    appLock.unlock()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        appLock.lockIfNeeded()
                    case .active:
                        appLock.unlock()
                    default:
                        break
                    }
                }
        }
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self])
    }
}
