import SwiftUI

struct ClockView: View {
    let currentHourFraction: Double
    let peakStartLocal: Double
    let peakEndLocal: Double

    private let clockSize: CGFloat = 190
    private let ringWidth: CGFloat = 16
    private let labelOffset: CGFloat = 16

    private var ringRadius: CGFloat {
        clockSize / 2 - labelOffset - ringWidth / 2
    }

    var body: some View {
        ZStack {
            canvas
            labels
        }
        .frame(width: clockSize, height: clockSize)
    }

    // MARK: - Labels

    private var labels: some View {
        ForEach(0..<8, id: \.self) { i in
            let hour = i * 3
            let isMajor = hour % 6 == 0
            let angle = self.angle(for: Double(hour))
            let r = clockSize / 2 - 8

            Text("\(hour)")
                .font(.system(
                    size: isMajor ? 12 : 10,
                    weight: isMajor ? .bold : .regular,
                    design: .monospaced
                ))
                .foregroundStyle(isMajor ? .primary : .secondary)
                .position(
                    x: clockSize / 2 + r * CGFloat(cos(angle)),
                    y: clockSize / 2 + r * CGFloat(sin(angle))
                )
        }
    }

    // MARK: - Canvas

    private var canvas: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            drawOffPeakRing(context: context, center: center)
            drawPeakArc(context: context, center: center)
            drawTickMarks(context: context, center: center)
            drawHand(context: context, center: center)
            drawTipDot(context: context, center: center)
            drawCenterDot(context: context, center: center)
        }
    }

    private func drawOffPeakRing(context: GraphicsContext, center: CGPoint) {
        var path = Path()
        path.addArc(
            center: center, radius: ringRadius,
            startAngle: .zero, endAngle: .degrees(360),
            clockwise: false
        )
        context.stroke(
            path,
            with: .color(.green.opacity(0.3)),
            style: StrokeStyle(lineWidth: ringWidth, lineCap: .butt)
        )
    }

    private func drawPeakArc(context: GraphicsContext, center: CGPoint) {
        let start = Angle.radians(angle(for: peakStartLocal))
        let end = Angle.radians(angle(for: peakEndLocal))
        var path = Path()
        path.addArc(
            center: center, radius: ringRadius,
            startAngle: start, endAngle: end,
            clockwise: false
        )
        context.stroke(
            path,
            with: .color(.orange.opacity(0.7)),
            style: StrokeStyle(lineWidth: ringWidth, lineCap: .butt)
        )
    }

    private func drawTickMarks(context: GraphicsContext, center: CGPoint) {
        for hour in 0..<24 {
            let a = angle(for: Double(hour))
            let isMajor = hour % 6 == 0
            let is3h = hour % 3 == 0

            let outerR = ringRadius + ringWidth / 2
            let tickLen: CGFloat = isMajor ? 7 : (is3h ? 5 : 3)
            let innerR = outerR - tickLen

            let p1 = CGPoint(
                x: center.x + outerR * CGFloat(cos(a)),
                y: center.y + outerR * CGFloat(sin(a))
            )
            let p2 = CGPoint(
                x: center.x + innerR * CGFloat(cos(a)),
                y: center.y + innerR * CGFloat(sin(a))
            )

            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)

            let opacity: Double = isMajor ? 0.7 : (is3h ? 0.4 : 0.2)
            let width: CGFloat = isMajor ? 1.5 : 0.8
            context.stroke(
                path,
                with: .color(.primary.opacity(opacity)),
                style: StrokeStyle(lineWidth: width)
            )
        }
    }

    private func drawHand(context: GraphicsContext, center: CGPoint) {
        let a = angle(for: currentHourFraction)
        let length = ringRadius - ringWidth / 2 - 6

        let end = CGPoint(
            x: center.x + length * CGFloat(cos(a)),
            y: center.y + length * CGFloat(sin(a))
        )

        // Thin tail (opposite direction)
        let tailLength: CGFloat = 12
        let tail = CGPoint(
            x: center.x - tailLength * CGFloat(cos(a)),
            y: center.y - tailLength * CGFloat(sin(a))
        )

        var path = Path()
        path.move(to: tail)
        path.addLine(to: end)
        context.stroke(
            path,
            with: .color(.red),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )
    }

    private func drawTipDot(context: GraphicsContext, center: CGPoint) {
        let a = angle(for: currentHourFraction)
        let pos = CGPoint(
            x: center.x + ringRadius * CGFloat(cos(a)),
            y: center.y + ringRadius * CGFloat(sin(a))
        )
        let r: CGFloat = 5
        let rect = CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)
        context.fill(Path(ellipseIn: rect), with: .color(.red))
    }

    private func drawCenterDot(context: GraphicsContext, center: CGPoint) {
        let r: CGFloat = 3.5
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        context.fill(Path(ellipseIn: rect), with: .color(.primary.opacity(0.7)))
    }

    // MARK: - Geometry

    private func angle(for hour: Double) -> Double {
        (hour / 24.0) * 2.0 * .pi - .pi / 2.0
    }
}
