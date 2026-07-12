import Foundation
import SwiftData

/// The kind of card a user stores. Selecting a template pre-populates the
/// editor with a sensible set of fields; the user can customize them freely.
enum CardTemplate: String, CaseIterable, Identifiable, Codable {
    case creditCard
    case idDocument
    case businessCard
    case loyalty
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .creditCard: return "Credit / Debit Card"
        case .idDocument: return "ID Document"
        case .businessCard: return "Business Card"
        case .loyalty: return "Loyalty Card"
        case .custom: return "Custom Card"
        }
    }

    var systemImage: String {
        switch self {
        case .creditCard: return "creditcard"
        case .idDocument: return "person.text.rectangle"
        case .businessCard: return "briefcase"
        case .loyalty: return "star"
        case .custom: return "rectangle.dashed"
        }
    }
}

/// Decorative pattern drawn on top of the card color when no photo is set.
enum PatternStyle: String, CaseIterable, Identifiable, Codable {
    case none
    case diagonalStripes
    case dots
    case waves
    case carbon
    case grid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Plain"
        case .diagonalStripes: return "Stripes"
        case .dots: return "Dots"
        case .waves: return "Waves"
        case .carbon: return "Carbon"
        case .grid: return "Grid"
        }
    }
}

/// A single card in the wallet: structured fields plus optional front/back
/// photos stored on disk through `ImageStore`.
@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var title: String
    /// Raw value of `CardTemplate`, stored as a plain string for SwiftData.
    var templateKey: String
    /// Hex color (RRGGBB, no leading `#`) used for the card face background.
    var colorHex: String
    /// Raw value of `PatternStyle`.
    var patternStyleRaw: String
    var frontImageFilename: String?
    var backImageFilename: String?
    /// User-defined position inside the wallet stack (lower = closer to top).
    var orderIndex: Int
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CardField.card)
    var fields: [CardField]

    init(
        title: String,
        template: CardTemplate,
        colorHex: String = CardPalette.defaultHex,
        pattern: PatternStyle = .none,
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.templateKey = template.rawValue
        self.colorHex = colorHex
        self.patternStyleRaw = pattern.rawValue
        self.frontImageFilename = nil
        self.backImageFilename = nil
        self.orderIndex = orderIndex
        self.createdAt = .now
        self.updatedAt = .now
        self.fields = []
    }

    // MARK: - Enum accessors (SwiftData-safe)

    var template: CardTemplate {
        get { CardTemplate(rawValue: templateKey) ?? .custom }
        set { templateKey = newValue.rawValue }
    }

    var pattern: PatternStyle {
        get { PatternStyle(rawValue: patternStyleRaw) ?? .none }
        set { patternStyleRaw = newValue.rawValue }
    }

    // MARK: - Derived data

    /// Fields in the order the user arranged them.
    var sortedFields: [CardField] {
        fields.sorted { $0.orderIndex < $1.orderIndex }
    }

    /// Fields marked sensitive, used for the generated card back.
    var sensitiveFields: [CardField] {
        sortedFields.filter(\.isSensitive)
    }

    /// One-line preview printed on the card face. Sensitive values are
    /// always masked here; plain values are shown as-is.
    var maskedPreview: String? {
        let candidates = sortedFields.filter { !$0.value.isEmpty }
        if let sensitive = candidates.first(where: \.isSensitive) {
            return sensitive.maskedValue
        }
        return candidates.first?.value
    }
}
