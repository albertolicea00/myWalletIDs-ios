import SwiftUI

/// Root navigation shell. For now a single wallet containing every card;
/// user-defined sections will later turn this into a TabView.
struct RootView: View {
    var body: some View {
        NavigationStack {
            WalletView(section: nil)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
