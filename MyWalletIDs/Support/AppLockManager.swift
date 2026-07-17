import LocalAuthentication
import SwiftUI

/// Gates the app behind Face ID / Touch ID (with passcode fallback).
/// The lock engages on launch and whenever the app moves to the background,
/// as long as the user enabled it in Settings.
@MainActor
final class AppLockManager: ObservableObject {
    static let enabledDefaultsKey = "appLockEnabled"

    @Published private(set) var isLocked = false
    private var isAuthenticating = false

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: Self.enabledDefaultsKey)
    }

    /// Locks immediately if the feature is enabled (launch / background).
    func lockIfNeeded() {
        if isEnabled {
            isLocked = true
        }
    }

    /// Prompts for biometrics / passcode and unlocks on success.
    func unlock() {
        guard isLocked, !isAuthenticating else { return }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // No passcode set on the device: fail open rather than
            // locking the user out of their own data.
            isLocked = false
            return
        }

        isAuthenticating = true
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock your wallet"
        ) { [weak self] success, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isAuthenticating = false
                if success {
                    self.isLocked = false
                }
            }
        }
    }

    /// Whether the device can authenticate at all (used by Settings).
    nonisolated static func biometricsAvailable() -> Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
}
