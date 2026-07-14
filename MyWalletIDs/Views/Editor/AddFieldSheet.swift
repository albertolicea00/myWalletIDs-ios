import SwiftUI

/// Small sheet used by the card editor to append a new custom field:
/// pick a type, name it, optionally mark it sensitive.
struct AddFieldSheet: View {
    let onAdd: (FieldDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var label = ""
    @State private var type: FieldType = .text
    @State private var isSensitive = false

    init(onAdd: @escaping (FieldDraft) -> Void) {
        self.onAdd = onAdd
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Label", text: $label)

                Picker("Type", selection: $type) {
                    ForEach(FieldType.allCases) { fieldType in
                        Label(fieldType.displayName, systemImage: fieldType.systemImage)
                            .tag(fieldType)
                    }
                }

                Toggle("Sensitive", isOn: $isSensitive)
            }
            .navigationTitle("Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: type) { _, newType in
                if newType.defaultsToSensitive {
                    isSensitive = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(
                            FieldDraft(
                                label: label.trimmingCharacters(in: .whitespaces),
                                type: type,
                                isSensitive: isSensitive
                            )
                        )
                        dismiss()
                    }
                    .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
