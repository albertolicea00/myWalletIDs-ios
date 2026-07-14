import PhotosUI
import SwiftData
import SwiftUI

/// Create/edit form for a card. Works on drafts so Cancel never mutates the
/// store: template picker (create only), dynamic field list with add /
/// remove / reorder / rename, color palette, pattern picker and front/back
/// photo pickers.
struct CardEditorView: View {
    private let card: Card?
    private let nextOrderIndex: Int

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var template: CardTemplate
    @State private var colorHex: String
    @State private var pattern: PatternStyle
    @State private var drafts: [FieldDraft]

    @State private var frontPickerItem: PhotosPickerItem?
    @State private var backPickerItem: PhotosPickerItem?
    @State private var frontImageData: Data?
    @State private var backImageData: Data?
    @State private var removeFrontImage = false
    @State private var removeBackImage = false

    @State private var isAddingField = false

    private var isCreating: Bool { card == nil }

    init(card: Card?, defaultTemplate: CardTemplate? = nil, nextOrderIndex: Int = 0) {
        self.card = card
        self.nextOrderIndex = nextOrderIndex
        if let card {
            _title = State(initialValue: card.title)
            _template = State(initialValue: card.template)
            _colorHex = State(initialValue: card.colorHex)
            _pattern = State(initialValue: card.pattern)
            _drafts = State(initialValue: card.sortedFields.map { FieldDraft(field: $0) })
        } else {
            let template = defaultTemplate ?? .creditCard
            _title = State(initialValue: "")
            _template = State(initialValue: template)
            _colorHex = State(initialValue: CardPalette.defaultHex)
            _pattern = State(initialValue: .none)
            _drafts = State(initialValue: FieldTemplates.fields(for: template).map { FieldDraft(seed: $0) })
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                cardSection
                fieldsSection
                appearanceSection
                imagesSection
            }
            .navigationTitle(isCreating ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $isAddingField) {
                AddFieldSheet { draft in
                    drafts.append(draft)
                }
            }
            .onChange(of: template) { _, newTemplate in
                repopulateDraftsIfPristine(for: newTemplate)
            }
            .onChange(of: frontPickerItem) { _, item in
                loadPickedImage(item) { data in
                    frontImageData = data
                    removeFrontImage = false
                }
            }
            .onChange(of: backPickerItem) { _, item in
                loadPickedImage(item) { data in
                    backImageData = data
                    removeBackImage = false
                }
            }
        }
    }

    // MARK: - Card section

    private var cardSection: some View {
        Section("Card") {
            TextField("Title", text: $title)

            if isCreating {
                Picker("Template", selection: $template) {
                    ForEach(CardTemplate.allCases) { template in
                        Label(template.displayName, systemImage: template.systemImage)
                            .tag(template)
                    }
                }
            } else {
                LabeledContent("Template", value: template.displayName)
            }
        }
    }

    // MARK: - Fields section

    private var fieldsSection: some View {
        Section {
            ForEach($drafts) { $draft in
                FieldDraftRow(draft: $draft)
            }
            .onDelete { offsets in
                drafts.remove(atOffsets: offsets)
            }
            .onMove { source, destination in
                drafts.move(fromOffsets: source, toOffset: destination)
            }

            Button {
                isAddingField = true
            } label: {
                Label("Add Field", systemImage: "plus.circle.fill")
            }
        } header: {
            HStack {
                Text("Fields")
                Spacer()
                if !drafts.isEmpty {
                    EditButton()
                        .font(.caption)
                }
            }
        } footer: {
            Text("Swipe left to delete a field. Use Edit to reorder.")
        }
    }

    // MARK: - Appearance section

    private var appearanceSection: some View {
        Section("Appearance") {
            livePreview
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

            colorPicker
            patternPicker
        }
    }

    private var livePreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: colorHex))
            LinearGradient(
                colors: [.white.opacity(0.22), .clear, .black.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PatternOverlay(style: pattern)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(title.isEmpty ? "Card Title" : title)
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: template.systemImage)
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(12)
        }
        .aspectRatio(CardFaceView.aspectRatio, contentMode: .fit)
        .frame(maxHeight: 130)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var colorPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
            ForEach(CardPalette.hexes, id: \.self) { hex in
                Button {
                    colorHex = hex
                } label: {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 34, height: 34)
                        .overlay {
                            if hex == colorHex {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Color \(hex)")
            }
        }
        .padding(.vertical, 4)
    }

    private var patternPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PatternStyle.allCases) { style in
                    Button {
                        pattern = style
                    } label: {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: colorHex))
                                .overlay(PatternOverlay(style: style, intensity: 0.25))
                                .frame(width: 62, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(
                                            style == pattern ? Color.accentColor : .clear,
                                            lineWidth: 2
                                        )
                                }
                            Text(style.displayName)
                                .font(.caption2)
                                .foregroundStyle(style == pattern ? Color.accentColor : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Images section

    private var imagesSection: some View {
        Section {
            imageRow(
                label: "Front Photo",
                pickerItem: $frontPickerItem,
                pickedData: frontImageData,
                existingFilename: removeFrontImage ? nil : card?.frontImageFilename,
                onRemove: {
                    frontImageData = nil
                    frontPickerItem = nil
                    removeFrontImage = true
                }
            )
            imageRow(
                label: "Back Photo",
                pickerItem: $backPickerItem,
                pickedData: backImageData,
                existingFilename: removeBackImage ? nil : card?.backImageFilename,
                onRemove: {
                    backImageData = nil
                    backPickerItem = nil
                    removeBackImage = true
                }
            )
        } header: {
            Text("Photos")
        } footer: {
            Text("When a front photo is set it replaces the colored card face.")
        }
    }

    @ViewBuilder
    private func imageRow(
        label: String,
        pickerItem: Binding<PhotosPickerItem?>,
        pickedData: Data?,
        existingFilename: String?,
        onRemove: @escaping () -> Void
    ) -> some View {
        let thumbnail = currentImage(pickedData: pickedData, existingFilename: existingFilename)

        HStack {
            PhotosPicker(selection: pickerItem, matching: .images) {
                Label(label, systemImage: "photo")
            }

            Spacer()

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove \(label)")
            }
        }
    }

    private func currentImage(pickedData: Data?, existingFilename: String?) -> UIImage? {
        if let pickedData, let image = UIImage(data: pickedData) {
            return image
        }
        return ImageStore.loadImage(named: existingFilename)
    }

    private func loadPickedImage(_ item: PhotosPickerItem?, assign: @escaping (Data) -> Void) {
        guard let item else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self) {
                assign(data)
            }
        }
    }

    // MARK: - Template switching

    /// When creating and no field has been filled in yet, switching template
    /// replaces the seeded fields. Once the user typed anything, keep them.
    private func repopulateDraftsIfPristine(for template: CardTemplate) {
        guard isCreating else { return }
        guard drafts.allSatisfy({ $0.value.isEmpty }) else { return }
        drafts = FieldTemplates.fields(for: template).map { FieldDraft(seed: $0) }
    }

    // MARK: - Save

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)

        if let card {
            card.title = trimmedTitle
            card.colorHex = colorHex
            card.pattern = pattern
            applyImages(to: card)
            reconcileFields(on: card)
            card.updatedAt = .now
        } else {
            let newCard = Card(
                title: trimmedTitle,
                template: template,
                colorHex: colorHex,
                pattern: pattern,
                orderIndex: nextOrderIndex
            )
            context.insert(newCard)
            applyImages(to: newCard)
            for (index, draft) in drafts.enumerated() {
                let field = CardField(
                    label: draft.label,
                    type: draft.type,
                    value: draft.value,
                    isSensitive: draft.isSensitive,
                    orderIndex: index
                )
                newCard.fields.append(field)
            }
        }

        try? context.save()
        dismiss()
    }

    private func applyImages(to card: Card) {
        if removeFrontImage {
            ImageStore.delete(card.frontImageFilename)
            card.frontImageFilename = nil
        }
        if let frontImageData {
            ImageStore.delete(card.frontImageFilename)
            card.frontImageFilename = ImageStore.save(frontImageData)
        }
        if removeBackImage {
            ImageStore.delete(card.backImageFilename)
            card.backImageFilename = nil
        }
        if let backImageData {
            ImageStore.delete(card.backImageFilename)
            card.backImageFilename = ImageStore.save(backImageData)
        }
    }

    /// Syncs draft state back into SwiftData: deletes removed fields,
    /// updates surviving ones and inserts new ones, preserving order.
    private func reconcileFields(on card: Card) {
        let existing = card.sortedFields
        let keptIDs = Set(drafts.compactMap(\.existingFieldID))

        for field in existing where !keptIDs.contains(field.id) {
            context.delete(field)
        }

        for (index, draft) in drafts.enumerated() {
            if let fieldID = draft.existingFieldID,
               let field = existing.first(where: { $0.id == fieldID }) {
                field.label = draft.label
                field.type = draft.type
                field.value = draft.value
                field.isSensitive = draft.isSensitive
                field.orderIndex = index
            } else {
                let field = CardField(
                    label: draft.label,
                    type: draft.type,
                    value: draft.value,
                    isSensitive: draft.isSensitive,
                    orderIndex: index
                )
                card.fields.append(field)
            }
        }
    }
}

#Preview {
    CardEditorView(card: nil)
        .modelContainer(for: [Card.self, CardField.self, WalletSection.self], inMemory: true)
}
