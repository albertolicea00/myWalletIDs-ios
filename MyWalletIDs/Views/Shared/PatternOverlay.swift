import SwiftUI

/// Draws the decorative card pattern with a SwiftUI `Canvas`.
/// Rendered on top of the card color with low opacity.
struct PatternOverlay: View {
    let style: PatternStyle
    var tint: Color = .white
    var intensity: Double = 0.14

    var body: some View {
        Canvas { context, size in
            let shading = GraphicsContext.Shading.color(tint.opacity(intensity))
            switch style {
            case .none:
                break
            case .diagonalStripes:
                drawDiagonalStripes(in: &context, size: size, shading: shading)
            case .dots:
                drawDots(in: &context, size: size, shading: shading)
            case .waves:
                drawWaves(in: &context, size: size, shading: shading)
            case .carbon:
                drawCarbon(in: &context, size: size, shading: shading)
            case .grid:
                drawGrid(in: &context, size: size, shading: shading)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawDiagonalStripes(
        in context: inout GraphicsContext,
        size: CGSize,
        shading: GraphicsContext.Shading
    ) {
        var path = Path()
        var x = -size.height
        while x < size.width {
            path.move(to: CGPoint(x: x, y: size.height))
            path.addLine(to: CGPoint(x: x + size.height, y: 0))
            x += 26
        }
        context.stroke(path, with: shading, lineWidth: 8)
    }

    private func drawDots(
        in context: inout GraphicsContext,
        size: CGSize,
        shading: GraphicsContext.Shading
    ) {
        var row = 0
        var y: CGFloat = 8
        while y < size.height {
            var x: CGFloat = row.isMultiple(of: 2) ? 8 : 17
            while x < size.width {
                let rect = CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5)
                context.fill(Path(ellipseIn: rect), with: shading)
                x += 18
            }
            y += 16
            row += 1
        }
    }

    private func drawWaves(
        in context: inout GraphicsContext,
        size: CGSize,
        shading: GraphicsContext.Shading
    ) {
        var y: CGFloat = 12
        while y < size.height + 10 {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            var x: CGFloat = 0
            while x < size.width {
                path.addQuadCurve(
                    to: CGPoint(x: x + 24, y: y),
                    control: CGPoint(x: x + 12, y: y - 10)
                )
                path.addQuadCurve(
                    to: CGPoint(x: x + 48, y: y),
                    control: CGPoint(x: x + 36, y: y + 10)
                )
                x += 48
            }
            context.stroke(path, with: shading, lineWidth: 2)
            y += 20
        }
    }

    private func drawCarbon(
        in context: inout GraphicsContext,
        size: CGSize,
        shading: GraphicsContext.Shading
    ) {
        let cell: CGFloat = 10
        var row = 0
        var y: CGFloat = 0
        while y < size.height {
            var column = 0
            var x: CGFloat = 0
            while x < size.width {
                if (row + column).isMultiple(of: 2) {
                    let rect = CGRect(x: x, y: y, width: cell, height: cell)
                    context.fill(Path(rect), with: shading)
                }
                x += cell
                column += 1
            }
            y += cell
            row += 1
        }
    }

    private func drawGrid(
        in context: inout GraphicsContext,
        size: CGSize,
        shading: GraphicsContext.Shading
    ) {
        var path = Path()
        var x: CGFloat = 0
        while x < size.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            x += 22
        }
        var y: CGFloat = 0
        while y < size.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            y += 22
        }
        context.stroke(path, with: shading, lineWidth: 1)
    }
}

#Preview {
    VStack {
        ForEach(PatternStyle.allCases) { style in
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .overlay(PatternOverlay(style: style))
                .frame(height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
}
