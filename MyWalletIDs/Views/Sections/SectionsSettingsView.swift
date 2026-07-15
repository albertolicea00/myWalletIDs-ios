import SwiftData
import SwiftUI

/// CRUD list for the user's wallet sections. Sections become tabs on the
/// root screen; with no visible sections the app falls back to a single
/// wallet without a tab bar.
struct SectionsSettingsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WalletSection.orderIndex) private var sections: [WalletSection]

    @State private var editingSection: WalletSection?
    @State private var isCreating = false

    var body: some View {
        List {
            if sections.isEmpty {
                ContentUnavailableView {
                    Label("No Sections", systemImage: "square.stack.3d.up.slash")
                } description: {
                    Text("Sections turn your wallet into tabs. Without them, all cards live in a single wallet.")
                }
            } else {
                ForEach(sections) { section in
                    row(for: section)
                }
                .onMove(perform: moveSections)
                .onDelete(perform: deleteSections)
            }
        }
        .navigationTitle("Sections")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isCreating = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Section")
            }
        }
        .sheet(isPresented: $isCreating) {
            SectionEditorView(section: nil, nextOrderIndex: sections.count)
        }
        .sheet(item: $editingSection) { section in
            SectionEditorView(section: section, nextOrderIndex: sections.count)
        }
    }

    private func row(for section: WalletSection) -> some View {
        Button {
            editingSection = section
        } label: {
            HStack(spacing: 12) {
                Image(systemName: section.iconSystemName)
                    .foregroundStyle(.tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.name)
                        .foregroundStyle(.primary)
                    Text(section.filterTemplate?.displayName ?? "All cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !section.isVisible {
                    Image(systemName: "eye.slash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                section.isVisible.toggle()
                try? context.save()
            } label: {
                Label(
                    section.isVisible ? "Hide" : "Show",
                    systemImage: section.isVisible ? "eye.slash" : "eye"
                )
            }
            .tint(.indigo)
        }
    }

    private func moveSections(from source: IndexSet, to destination: Int) {
        var reordered = sections
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, section) in reordered.enumerated() {
            section.orderIndex = index
        }
        try? context.save()
    }

    private func deleteSections(at offsets: IndexSet) {
        for index in offsets {
            context.delete(sections[index])
        }
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        SectionsSettingsView()
    }
    .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
