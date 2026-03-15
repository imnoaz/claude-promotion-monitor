import SwiftUI

struct StatusView: View {
    @ObservedObject var timeManager: TimeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            Divider()
            statusCard
            clockSection
            promotionCard
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 320)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.orange)
                .font(.title3)
            Text("Claude Promotion Monitor")
                .font(.headline)
            Spacer()
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        HStack {
            Circle()
                .fill(timeManager.statusColor)
                .frame(width: 10, height: 10)
            Text(timeManager.statusText)
                .font(.system(.title3, weight: .semibold))
            Spacer()
            if timeManager.isPromotionActive {
                Text(timeManager.isPeakHours ? "1×" : "2×")
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(timeManager.statusColor)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Clock Section

    private var clockSection: some View {
        VStack(spacing: 8) {
            Text(timeManager.statusDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ClockView(
                currentHourFraction: timeManager.currentHourFractionLocal,
                peakStartLocal: timeManager.peakStartHourLocal,
                peakEndLocal: timeManager.peakEndHourLocal
            )
            .frame(maxWidth: .infinity)

            HStack {
                Text(timeManager.nextChangeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(timeManager.formatTimeInterval(timeManager.timeUntilNextChange))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Promotion Card

    private var promotionCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: promotionIcon)
                    .foregroundStyle(promotionColor)
                Text("プロモーション")
                    .font(.system(.subheadline, weight: .medium))
                Spacer()
                Text(promotionStatusLabel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(promotionColor.opacity(0.15))
                    .foregroundStyle(promotionColor)
                    .clipShape(Capsule())
            }

            if timeManager.isPromotionActive {
                HStack {
                    Text("残り")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeManager.formatTimeInterval(timeManager.timeUntilPromotionEnd))
                        .font(.system(.caption, design: .monospaced))
                    Spacer()
                    Text(timeManager.promotionPeriodLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if timeManager.isPromotionUpcoming {
                HStack {
                    Text("開始まで")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeManager.formatTimeInterval(timeManager.timeUntilPromotionEnd))
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var promotionIcon: String {
        if timeManager.isPromotionActive { return "gift.fill" }
        if timeManager.isPromotionUpcoming { return "clock.fill" }
        return "gift"
    }

    private var promotionColor: Color {
        if timeManager.isPromotionActive { return .green }
        if timeManager.isPromotionUpcoming { return .blue }
        return .secondary
    }

    private var promotionStatusLabel: String {
        if timeManager.isPromotionActive { return "有効" }
        if timeManager.isPromotionUpcoming { return "開始前" }
        return "終了"
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)

            Spacer()

            Text("v1.0.0")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
