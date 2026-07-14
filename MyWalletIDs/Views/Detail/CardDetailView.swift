import SwiftData
import SwiftUI

/// Card detail: a hero card that flips in 3D between front and back,
/// followed by the list of fields with copy and reveal controls.
struct CardDetailView: View {
    let card: Card

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isFlipped = false
    @State private var frontDegrees: Double = 0
    @State private var backDegrees: Double = -90
    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    private static let flipDuration = 0.18

    init(card: Card) {
        self.card = card
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroCard
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                fieldList
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete Card")
            }
        }
        .sheet(isPresented: $isEditing) {
            CardEditorView(card: card)
        }
        .confirmationDialog(
            "Delete Card",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteCard()
            }
        } message: {
            Text("This permanently deletes \"\(card.title)\" and all of its fields.")
        }
    }

    // MARK: - Hero card with flip

    private var heroCard: some View {
        ZStack {
            CardFaceView(card: card, side: .front)
                .rotation3DEffect(
                    .degrees(frontDegrees),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(abs(frontDegrees) >= 90 ? 0 : 1)

            CardFaceView(card: card, side: .back)
                .rotation3DEffect(
                    .degrees(backDegrees),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(abs(backDegrees) >= 90 ? 0 : 1)
        }
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
        .onTapGesture {
            flip()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(isFlipped ? "Show card front" : "Show card back")
    }

    /// Two-stage flip: the visible face rotates to 90° (edge-on), then the
    /// other face rotates in from -90°, so the swap happens exactly at 90°.
    private func flip() {
        if isFlipped {
            withAnimation(.easeIn(duration: Self.flipDuration)) {
                backDegrees = -90
            }
            withAnimation(.easeOut(duration: Self.flipDuration).delay(Self.flipDuration)) {
                frontDegrees = 0
            }
        } else {
            withAnimation(.easeIn(duration: Self.flipDuration)) {
                frontDegrees = 90
            }
            withAnimation(.easeOut(duration: Self.flipDuration).delay(Self.flipDuration)) {
                backDegrees = 0
            }
        }
        isFlipped.toggle()
    }

    // MARK: - Fields

    private var fieldList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if card.sortedFields.isEmpty {
                Text("No fields yet. Tap Edit to add some.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(card.sortedFields) { field in
                    FieldRowView(field: field)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    if field.id != card.sortedFields.last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    // MARK: - Actions

    private func deleteCard() {
        ImageStore.deleteImages(of: card)
        context.delete(card)
        try? context.save()
        dismiss()
    }
}
