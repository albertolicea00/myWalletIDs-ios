import SwiftUI
import UIKit

/// One field on the detail screen: label, value, copy button and — for
/// sensitive fields — an eye toggle that reveals the masked value.
struct FieldRowView: View {
    let field: CardField

    @State private var isRevealed = false
    @State private var justCopied = false

    init(field: CardField) {
        self.field = field
    }

    private var displayValue: String {
        guard !field.value.isEmpty else { return "—" }
        if field.isSensitive && !isRevealed {
            return field.maskedValue
        }
        return field.value
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: field.type.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(field.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(displayValue)
                    .font(field.isSensitive ? .body.monospaced() : .body)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 8)

            if field.isSensitive {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isRevealed.toggle()
                    }
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(isRevealed ? "Hide value" : "Reveal value")
            }

            Button {
                copyValue()
            } label: {
                Image(systemName: justCopied ? "checkmark" : "doc.on.doc")
                    .foregroundStyle(justCopied ? .green : .accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(field.value.isEmpty)
            .accessibilityLabel("Copy value")
        }
        .padding(.vertical, 2)
    }

    private func copyValue() {
        UIPasteboard.general.string = field.value
        justCopied = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            justCopied = false
        }
    }
}
