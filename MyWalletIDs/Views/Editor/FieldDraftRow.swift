import SwiftUI

/// Editable row for one field draft: rename the label inline, edit the
/// value with a type-appropriate control, toggle sensitivity.
struct FieldDraftRow: View {
    @Binding var draft: FieldDraft

    init(draft: Binding<FieldDraft>) {
        _draft = draft
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: draft.type.systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 18)

                TextField("Label", text: $draft.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    draft.isSensitive.toggle()
                } label: {
                    Image(systemName: draft.isSensitive ? "eye.slash.fill" : "eye")
                        .font(.caption)
                        .foregroundStyle(draft.isSensitive ? Color.accentColor : .secondary)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(draft.isSensitive ? "Mark as not sensitive" : "Mark as sensitive")
            }

            valueInput
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var valueInput: some View {
        switch draft.type {
        case .date:
            DatePicker("Value", selection: dateBinding, displayedComponents: .date)
                .labelsHidden()
        case .secret:
            SecureField("Value", text: $draft.value)
        case .note:
            TextField("Value", text: $draft.value, axis: .vertical)
                .lineLimit(2...4)
        case .number:
            TextField("Value", text: $draft.value)
                .keyboardType(.numbersAndPunctuation)
        case .phone:
            TextField("Value", text: $draft.value)
                .keyboardType(.phonePad)
        case .email:
            TextField("Value", text: $draft.value)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        case .url:
            TextField("Value", text: $draft.value)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        case .text:
            TextField("Value", text: $draft.value)
        }
    }

    /// Bridges the persisted "yyyy-MM-dd" string to a `DatePicker`.
    private var dateBinding: Binding<Date> {
        Binding<Date>(
            get: { FieldDateFormat.date(from: draft.value) ?? .now },
            set: { draft.value = FieldDateFormat.string(from: $0) }
        )
    }
}
