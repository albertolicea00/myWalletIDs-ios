import SwiftData
import SwiftUI

/// The wallet itself: cards stacked vertically like in a real wallet, each
/// one peeking out from under the previous and sliding free as you scroll.
struct WalletView: View {
    let section: WalletSection?

    @Environment(\.modelContext) private var context
    @Query(sort: \Card.orderIndex) private var cards: [Card]
    @State private var isPresentingEditor = false

    /// How much of each card stays visible under the next one.
    private static let visiblePeek: CGFloat = 72
    private static let estimatedCardHeight: CGFloat = 214

    init(section: WalletSection?) {
        self.section = section
    }

    private var filteredCards: [Card] {
        guard let section else { return cards }
        return cards.filter(section.matches)
    }

    var body: some View {
        Group {
            if filteredCards.isEmpty {
                emptyState
            } else {
                stackedList
            }
        }
        .navigationTitle(section?.name ?? "My Wallet")
        .navigationDestination(for: Card.self) { card in
            CardDetailView(card: card)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Card")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            CardEditorView(
                card: nil,
                defaultTemplate: section?.filterTemplate,
                nextOrderIndex: (cards.map(\.orderIndex).max() ?? -1) + 1
            )
        }
    }

    // MARK: - Stacked list

    private var stackedList: some View {
        ScrollView {
            LazyVStack(spacing: Self.visiblePeek - Self.estimatedCardHeight) {
                ForEach(filteredCards) { card in
                    NavigationLink(value: card) {
                        CardFaceView(card: card)
                            .shadow(color: .black.opacity(0.25), radius: 7, x: 0, y: -4)
                            .scrollTransition(axis: .vertical) { content, phase in
                                content
                                    .offset(y: phase.value * -26)
                                    .scaleEffect(
                                        phase.isIdentity ? 1 : 0.97,
                                        anchor: .top
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        contextMenu(for: card)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 48)
        }
    }

    @ViewBuilder
    private func contextMenu(for card: Card) -> some View {
        let index = filteredCards.firstIndex(of: card) ?? 0
        Button {
            move(card, by: -1)
        } label: {
            Label("Move Up", systemImage: "arrow.up")
        }
        .disabled(index == 0)

        Button {
            move(card, by: 1)
        } label: {
            Label("Move Down", systemImage: "arrow.down")
        }
        .disabled(index == filteredCards.count - 1)

        Divider()

        Button(role: .destructive) {
            delete(card)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Cards Yet", systemImage: "wallet.passes")
        } description: {
            Text("Your wallet is empty. Add a card to get started.")
        } actions: {
            Button {
                isPresentingEditor = true
            } label: {
                Label("Add Card", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func move(_ card: Card, by offset: Int) {
        let list = filteredCards
        guard let index = list.firstIndex(of: card) else { return }
        let target = index + offset
        guard list.indices.contains(target) else { return }
        let other = list[target]
        swap(&card.orderIndex, &other.orderIndex)
        try? context.save()
    }

    private func delete(_ card: Card) {
        ImageStore.deleteImages(of: card)
        context.delete(card)
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        WalletView(section: nil)
    }
    .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
