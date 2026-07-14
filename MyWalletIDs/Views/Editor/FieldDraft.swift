import Foundation

/// In-memory, cancelable working copy of a card field used by the editor.
/// Drafts are only written back to SwiftData when the user taps Save.
struct FieldDraft: Identifiable, Equatable {
    let id: UUID
    var label: String
    var type: FieldType
    var value: String
    var isSensitive: Bool
    /// `id` of the persisted `CardField` this draft mirrors, if any.
    let existingFieldID: UUID?

    init(
        label: String,
        type: FieldType,
        value: String = "",
        isSensitive: Bool = false
    ) {
        self.id = UUID()
        self.label = label
        self.type = type
        self.value = value
        self.isSensitive = isSensitive
        self.existingFieldID = nil
    }

    init(seed: FieldSeed) {
        self.id = UUID()
        self.label = seed.label
        self.type = seed.type
        self.value = ""
        self.isSensitive = seed.isSensitive
        self.existingFieldID = nil
    }

    init(field: CardField) {
        self.id = UUID()
        self.label = field.label
        self.type = field.type
        self.value = field.value
        self.isSensitive = field.isSensitive
        self.existingFieldID = field.id
    }
}
