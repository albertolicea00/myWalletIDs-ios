import SwiftUI

enum CardSide {
    case front
    case back
}

/// Reusable card rendering used by the wallet stack, the detail hero and
/// the flip animation. Shows the stored photo when available, otherwise a
/// colored face with a subtle gradient, a Canvas pattern, the title and a
/// masked preview line.
struct CardFaceView: View {
    let card: Card
    var side: CardSide = .front

    /// Standard ID-1 card ratio (85.60 × 53.98 mm).
    static let aspectRatio: CGFloat = 1.586
    private static let cornerRadius: CGFloat = 16

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
    }

    private var baseColor: Color {
        Color(hex: card.colorHex)
    }

    private var imageFilename: String? {
        side == .front ? card.frontImageFilename : card.backImageFilename
    }

    var body: some View {
        Group {
            if let image = ImageStore.loadImage(named: imageFilename) {
                photoFace(image)
            } else if side == .front {
                coloredFront
            } else {
                generatedBack
            }
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        .clipShape(shape)
        .contentShape(shape)
    }

    // MARK: - Photo

    private func photoFace(_ image: UIImage) -> some View {
        Color.clear
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
            .overlay(alignment: .topLeading) {
                if side == .front {
                    Text(card.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.35), in: Capsule())
                        .padding(12)
                }
            }
    }

    // MARK: - Colored front

    private var coloredFront: some View {
        ZStack {
            shape.fill(baseColor)
            LinearGradient(
                colors: [.white.opacity(0.22), .clear, .black.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            PatternOverlay(style: card.pattern)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(card.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                    Image(systemName: card.template.systemImage)
                        .font(.title3)
                        .opacity(0.85)
                }
                Spacer()
                if let preview = card.maskedPreview {
                    Text(preview)
                        .font(.subheadline.monospaced())
                        .lineLimit(1)
                        .opacity(0.92)
                }
            }
            .foregroundStyle(.white)
            .padding(16)
        }
    }

    // MARK: - Generated back

    private var generatedBack: some View {
        ZStack {
            shape.fill(baseColor)
            LinearGradient(
                colors: [.black.opacity(0.30), .black.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            PatternOverlay(style: card.pattern, intensity: 0.08)

            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .fill(.black.opacity(0.75))
                    .frame(height: 34)
                    .padding(.top, 14)
                    .padding(.horizontal, -16)

                if card.sensitiveFields.isEmpty {
                    Spacer()
                    Text("No sensitive fields")
                        .font(.footnote)
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(card.sensitiveFields.prefix(4)) { field in
                            HStack {
                                Text(field.label)
                                    .font(.caption2)
                                    .opacity(0.75)
                                Spacer()
                                Text(field.value.isEmpty ? "—" : field.value)
                                    .font(.footnote.monospaced())
                                    .lineLimit(1)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .foregroundStyle(.white)
            .padding(16)
        }
    }
}
