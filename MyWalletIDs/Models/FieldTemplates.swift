import Foundation

/// Blueprint for a field created from a system template. Seeds are turned
/// into editable drafts in the card editor, so the user can add, remove or
/// rename anything afterwards.
struct FieldSeed {
    let label: String
    let type: FieldType
    let isSensitive: Bool

    init(_ label: String, _ type: FieldType, sensitive: Bool = false) {
        self.label = label
        self.type = type
        self.isSensitive = sensitive
    }
}

/// System field templates. Selecting a template in the editor pre-populates
/// the field list with these seeds.
enum FieldTemplates {
    static func fields(for template: CardTemplate) -> [FieldSeed] {
        switch template {
        case .creditCard:
            return [
                FieldSeed("Card Number", .number, sensitive: true),
                FieldSeed("Cardholder", .text),
                FieldSeed("Expiry Date", .date),
                FieldSeed("CVV", .secret, sensitive: true),
                FieldSeed("Bank", .text),
                FieldSeed("Notes", .note)
            ]
        case .idDocument:
            return [
                FieldSeed("Document Type", .text),
                FieldSeed("Document Number", .text, sensitive: true),
                FieldSeed("Full Name", .text),
                FieldSeed("Date of Birth", .date),
                FieldSeed("Issue Date", .date),
                FieldSeed("Expiry Date", .date),
                FieldSeed("Issuing Authority", .text)
            ]
        case .businessCard:
            return [
                FieldSeed("Full Name", .text),
                FieldSeed("Company", .text),
                FieldSeed("Job Title", .text),
                FieldSeed("Phone", .phone),
                FieldSeed("Email", .email),
                FieldSeed("Website", .url),
                FieldSeed("Address", .text)
            ]
        case .loyalty:
            return [
                FieldSeed("Program", .text),
                FieldSeed("Member Number", .number),
                FieldSeed("Tier", .text),
                FieldSeed("Notes", .note)
            ]
        case .custom:
            return []
        }
    }
}
