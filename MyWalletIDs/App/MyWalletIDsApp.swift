import SwiftData
import SwiftUI

@main
struct MyWalletIDsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self])
    }
}
