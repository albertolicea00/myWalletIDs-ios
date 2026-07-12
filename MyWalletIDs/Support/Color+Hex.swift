import SwiftUI

extension Color {
    /// Creates a color from an "RRGGBB" hex string (leading "#" allowed).
    /// Falls back to gray for malformed input.
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        guard cleaned.count == 6, Scanner(string: cleaned).scanHexInt64(&value) else {
            self = .gray
            return
        }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

/// Preset palette offered by the card editor.
enum CardPalette {
    static let defaultHex = "1D4ED8"

    static let hexes: [String] = [
        "111827", // near black
        "1E293B", // slate
        "4B5563", // gray
        "B91C1C", // red
        "C2410C", // orange
        "A16207", // amber
        "15803D", // green
        "0F766E", // teal
        "0E7490", // cyan
        "1D4ED8", // blue
        "7C3AED", // violet
        "BE185D"  // pink
    ]
}
