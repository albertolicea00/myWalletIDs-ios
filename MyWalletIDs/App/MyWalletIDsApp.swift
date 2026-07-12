import SwiftData
import SwiftUI

@main
struct MyWalletIDsApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Image(systemName: "wallet.passes")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("My Wallet IDs")
                    .font(.title2.bold())
            }
        }
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self])
    }
}
