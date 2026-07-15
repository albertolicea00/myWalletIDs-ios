import SwiftData
import SwiftUI

/// Create/edit form for one wallet section: free-text name, curated SF
/// Symbol, optional template filter and visibility.
struct SectionEditorView: View {
    private let section: WalletSection?
    private let nextOrderIndex: Int

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var iconSystemName: String
    @State private var filterTemplate: CardTemplate?
    @State private var isVisible: Bool

    /// Curated symbols offered for tab icons.
    static let symbols: [String] = [
        "wallet.passes",
        "creditcard",
        "person.text.rectangle",
        "briefcase",
        "star",
        "tag",
        "gift",
        "car",
        "heart",
        "building.2"
    ]

    init(section: WalletSection?, nextOrderIndex: Int = 0) {
        self.section = section
        self.nextOrderIndex = nextOrderIndex
        if let section {
            _name = State(initialValue: section.name)
            _iconSystemName = State(initialValue: section.iconSystemName)
            _filterTemplate = State(initialValue: section.filterTemplate)
            _isVisible = State(initialValue: section.isVisible)
        } else {
            _name = State(initialValue: "")
            _iconSystemName = State(initialValue: Self.symbols[0])
            _filterTemplate = State(initialValue: nil)
            _isVisible = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Section name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Self.symbols, id: \.self) { symbol in
                            Button {
                                iconSystemName = symbol
                            } label: {
                                Image(systemName: symbol)
                                    .font(.title3)
                                    .frame(width: 46, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(
                                                symbol == iconSystemName
                                                    ? Color.accentColor.opacity(0.18)
                                                    : Color.clear
                                            )
                                    )
                                    .foregroundStyle(
                                        symbol == iconSystemName ? Color.accentColor : .primary
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(symbol)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Picker("Show", selection: $filterTemplate) {
                        Text("All cards").tag(CardTemplate?.none)
                        ForEach(CardTemplate.allCases) { template in
                            Label(template.displayName, systemImage: template.systemImage)
                                .tag(CardTemplate?.some(template))
                        }
                    }

                    Toggle("Visible", isOn: $isVisible)
                } header: {
                    Text("Filter")
                } footer: {
                    Text("A section shows only cards of the chosen template. Hidden sections keep their settings but do not appear as tabs.")
                }
            }
            .navigationTitle(section == nil ? "New Section" : "Edit Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let section {
            section.name = trimmedName
            section.iconSystemName = iconSystemName
            section.filterTemplate = filterTemplate
            section.isVisible = isVisible
        } else {
            let newSection = WalletSection(
                name: trimmedName,
                iconSystemName: iconSystemName,
                templateFilter: filterTemplate,
                orderIndex: nextOrderIndex,
                isVisible: isVisible
            )
            context.insert(newSection)
        }

        try? context.save()
        dismiss()
    }
}

#Preview {
    SectionEditorView(section: nil)
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
