import Foundation

/// Shared formatter for date-typed field values. Values are persisted as
/// plain "yyyy-MM-dd" strings so they stay readable and locale-stable.
enum FieldDateFormat {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func date(from value: String) -> Date? {
        formatter.date(from: value)
    }

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
