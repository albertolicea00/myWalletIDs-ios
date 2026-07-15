import SwiftData
import SwiftUI

/// Switches the navigation shell based on the user's sections:
/// - No visible sections → a single wallet with every card, no tab bar.
/// - One or more visible sections → a TabView with one tab per section.
struct RootView: View {
    @Query(sort: \WalletSection.orderIndex) private var sections: [WalletSection]

    private var visibleSections: [WalletSection] {
        sections.filter(\.isVisible)
    }

    var body: some View {
        if visibleSections.isEmpty {
            NavigationStack {
                WalletView(section: nil)
            }
        } else {
            TabView {
                ForEach(visibleSections) { section in
                    NavigationStack {
                        WalletView(section: section)
                    }
                    .tabItem {
                        Label(section.name, systemImage: section.iconSystemName)
                    }
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
