import SwiftUI

/// Full-screen cover shown while the app is locked. Hides all content
/// underneath and offers a manual retry button.
struct LockScreenView: View {
    @EnvironmentObject private var appLock: AppLockManager

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 46, weight: .medium))
                    .foregroundStyle(.tint)

                Text("My Wallet IDs is locked")
                    .font(.headline)

                Text("Authenticate to access your cards.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    appLock.unlock()
                } label: {
                    Label("Unlock", systemImage: "faceid")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}
