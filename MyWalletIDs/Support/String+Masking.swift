import Foundation

extension String {
    /// Masks a value keeping only the trailing characters visible:
    /// "4111 1111 1111 4242" → "•••• 4242". Short values are fully hidden.
    func masked(keepingLast visibleCount: Int = 4) -> String {
        let compact = replacingOccurrences(of: " ", with: "")
        guard compact.count > visibleCount else {
            return String(repeating: "•", count: Swift.max(compact.count, 4))
        }
        return "•••• " + compact.suffix(visibleCount)
    }
}
