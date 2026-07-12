import Foundation
import SwiftData

/// The semantic type of a field's value. Drives keyboard type, input
/// control and default sensitivity in the editor.
enum FieldType: String, CaseIterable, Identifiable, Codable {
    case text
    case number
    case phone
    case email
    case url
    case date
    case secret
    case note

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .number: return "Number"
        case .phone: return "Phone"
        case .email: return "Email"
        case .url: return "Website"
        case .date: return "Date"
        case .secret: return "Secret"
        case .note: return "Note"
        }
    }

    var systemImage: String {
        switch self {
        case .text: return "textformat"
        case .number: return "number"
        case .phone: return "phone"
        case .email: return "envelope"
        case .url: return "link"
        case .date: return "calendar"
        case .secret: return "key"
        case .note: return "note.text"
        }
    }

    /// Secrets start out sensitive; everything else is opt-in.
    var defaultsToSensitive: Bool { self == .secret }
}

/// One labeled value on a card (e.g. "Card Number" → "4111 ...").
@Model
final class CardField {
    @Attribute(.unique) var id: UUID
    var label: String
    /// Raw value of `FieldType`, stored as a plain string for SwiftData.
    var typeRaw: String
    var value: String
    /// Sensitive values are masked by default and require an explicit
    /// reveal (eye toggle) in the detail screen.
    var isSensitive: Bool
    var orderIndex: Int
    var card: Card?

    init(
        label: String,
        type: FieldType,
        value: String = "",
        isSensitive: Bool = false,
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.label = label
        self.typeRaw = type.rawValue
        self.value = value
        self.isSensitive = isSensitive
        self.orderIndex = orderIndex
    }

    // MARK: - Enum accessor (SwiftData-safe)

    var type: FieldType {
        get { FieldType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
    }

    /// Masked representation keeping only the last characters visible,
    /// e.g. "•••• 4242".
    var maskedValue: String {
        value.masked()
    }
}
