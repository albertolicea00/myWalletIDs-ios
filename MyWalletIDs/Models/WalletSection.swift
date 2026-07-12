import Foundation
import SwiftData

/// A user-defined tab in the wallet. Sections are optional: with no visible
/// sections the app shows a single wallet containing every card; once at
/// least one visible section exists, each section becomes a tab that filters
/// cards by template.
@Model
final class WalletSection {
    @Attribute(.unique) var id: UUID
    /// Free text chosen by the user ("Bank", "Documents", "Work"...).
    var name: String
    /// SF Symbol shown on the tab item.
    var iconSystemName: String
    /// Raw value of `CardTemplate` used to filter cards. `nil` shows all.
    var templateFilter: String?
    var orderIndex: Int
    var isVisible: Bool

    init(
        name: String,
        iconSystemName: String = "wallet.passes",
        templateFilter: CardTemplate? = nil,
        orderIndex: Int = 0,
        isVisible: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.iconSystemName = iconSystemName
        self.templateFilter = templateFilter?.rawValue
        self.orderIndex = orderIndex
        self.isVisible = isVisible
    }

    // MARK: - Enum accessor (SwiftData-safe)

    var filterTemplate: CardTemplate? {
        get { templateFilter.flatMap(CardTemplate.init(rawValue:)) }
        set { templateFilter = newValue?.rawValue }
    }

    /// Whether a card belongs to this section.
    func matches(_ card: Card) -> Bool {
        guard let templateFilter else { return true }
        return card.templateKey == templateFilter
    }
}
