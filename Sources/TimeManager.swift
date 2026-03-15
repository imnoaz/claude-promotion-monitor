import Foundation
import SwiftUI

@MainActor
class TimeManager: ObservableObject {
    @Published var isPeakHours: Bool = false
    @Published var isPromotionActive: Bool = false
    @Published var isPromotionUpcoming: Bool = false
    @Published var timeUntilNextChange: TimeInterval = 0
    @Published var timeUntilPromotionEnd: TimeInterval = 0
    @Published var peakProgress: Double = 0

    @Published var currentHourFractionLocal: Double = 0
    @Published var peakStartHourLocal: Double = 0
    @Published var peakEndHourLocal: Double = 0

    private var timer: Timer?
    private let etTimeZone = TimeZone(identifier: "America/New_York")!

    private let promotionStart: Date
    private let promotionEnd: Date

    let peakStartHour = 8
    let peakEndHour = 14

    var menuBarText: String {
        if isPromotionActive {
            return isPeakHours ? "1×" : "2×"
        }
        return ""
    }

    var menuBarIcon: String {
        if isPromotionActive && !isPeakHours {
            return "bolt.fill"
        } else if isPeakHours {
            return "gauge.with.dots.needle.50percent"
        }
        return "gauge.with.dots.needle.0percent"
    }

    var statusText: String {
        isPeakHours ? "ピーク時間" : "オフピーク時間"
    }

    var statusDescription: String {
        if isPromotionActive {
            if isPeakHours {
                return "通常の使用量制限が適用されています"
            } else {
                return "使用量2倍！ボーナス分は週間制限にカウントされません"
            }
        } else if isPromotionUpcoming {
            return "プロモーション開始までお待ちください"
        } else {
            return "プロモーション期間は終了しました"
        }
    }

    var statusColor: Color {
        if isPromotionActive && !isPeakHours {
            return .green
        } else if isPeakHours {
            return .orange
        }
        return .secondary
    }

    var nextChangeLabel: String {
        isPeakHours ? "オフピークまで" : "ピークまで"
    }

    var promotionPeriodLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.timeZone = etTimeZone
        let start = formatter.string(from: promotionStart)
        let end = formatter.string(from: promotionEnd - 1)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: promotionStart)
        return "\(start) - \(end), \(year)"
    }

    init() {
        var calendar = Calendar.current
        calendar.timeZone = etTimeZone

        var startComponents = DateComponents()
        startComponents.year = 2026
        startComponents.month = 3
        startComponents.day = 13
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 0
        promotionStart = calendar.date(from: startComponents)!

        var endComponents = DateComponents()
        endComponents.year = 2026
        endComponents.month = 3
        endComponents.day = 28
        endComponents.hour = 0
        endComponents.minute = 0
        endComponents.second = 0
        promotionEnd = calendar.date(from: endComponents)!

        update()
        startTimer()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.update()
            }
        }
    }

    func update() {
        let now = Date()

        var etCalendar = Calendar.current
        etCalendar.timeZone = etTimeZone

        let hour = etCalendar.component(.hour, from: now)
        isPeakHours = hour >= peakStartHour && hour < peakEndHour

        isPromotionActive = now >= promotionStart && now < promotionEnd
        isPromotionUpcoming = now < promotionStart

        updatePeakProgress(now: now, calendar: etCalendar, hour: hour)
        updateTimeUntilNextChange(now: now, calendar: etCalendar)
        updatePromotionCountdown(now: now)
        updateLocalClockData(now: now)
    }

    private func updatePeakProgress(now: Date, calendar: Calendar, hour: Int) {
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)

        if isPeakHours {
            let elapsed = Double((hour - peakStartHour) * 3600 + minute * 60 + second)
            let total = Double((peakEndHour - peakStartHour) * 3600)
            peakProgress = elapsed / total
        } else {
            if hour >= peakEndHour {
                let elapsed = Double((hour - peakEndHour) * 3600 + minute * 60 + second)
                let total = Double((24 - peakEndHour + peakStartHour) * 3600)
                peakProgress = elapsed / total
            } else {
                let elapsed = Double((24 - peakEndHour + hour) * 3600 + minute * 60 + second)
                let total = Double((24 - peakEndHour + peakStartHour) * 3600)
                peakProgress = elapsed / total
            }
        }
    }

    private func updateTimeUntilNextChange(now: Date, calendar: Calendar) {
        if isPeakHours {
            var comps = calendar.dateComponents([.year, .month, .day], from: now)
            comps.hour = peakEndHour
            comps.minute = 0
            comps.second = 0
            if let nextChange = calendar.date(from: comps) {
                timeUntilNextChange = nextChange.timeIntervalSince(now)
            }
        } else {
            var comps = calendar.dateComponents([.year, .month, .day], from: now)
            comps.hour = peakStartHour
            comps.minute = 0
            comps.second = 0
            if let nextChange = calendar.date(from: comps) {
                if nextChange <= now {
                    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: nextChange) {
                        timeUntilNextChange = tomorrow.timeIntervalSince(now)
                    }
                } else {
                    timeUntilNextChange = nextChange.timeIntervalSince(now)
                }
            }
        }
    }

    private func updatePromotionCountdown(now: Date) {
        if isPromotionActive {
            timeUntilPromotionEnd = promotionEnd.timeIntervalSince(now)
        } else if isPromotionUpcoming {
            timeUntilPromotionEnd = promotionStart.timeIntervalSince(now)
        } else {
            timeUntilPromotionEnd = 0
        }
    }

    private func updateLocalClockData(now: Date) {
        let localCalendar = Calendar.current
        let comps = localCalendar.dateComponents([.hour, .minute, .second], from: now)
        currentHourFractionLocal = Double(comps.hour ?? 0)
            + Double(comps.minute ?? 0) / 60.0
            + Double(comps.second ?? 0) / 3600.0

        let today = localCalendar.startOfDay(for: now)

        var startComps = localCalendar.dateComponents([.year, .month, .day], from: today)
        startComps.hour = peakStartHour
        startComps.minute = 0
        startComps.timeZone = etTimeZone

        var endComps = localCalendar.dateComponents([.year, .month, .day], from: today)
        endComps.hour = peakEndHour
        endComps.minute = 0
        endComps.timeZone = etTimeZone

        if let startDate = localCalendar.date(from: startComps),
           let endDate = localCalendar.date(from: endComps) {
            let localStart = localCalendar.dateComponents([.hour, .minute], from: startDate)
            let localEnd = localCalendar.dateComponents([.hour, .minute], from: endDate)
            peakStartHourLocal = Double(localStart.hour ?? 0) + Double(localStart.minute ?? 0) / 60.0
            peakEndHourLocal = Double(localEnd.hour ?? 0) + Double(localEnd.minute ?? 0) / 60.0
        }
    }

    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(max(0, interval))
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if days > 0 {
            return String(format: "%dd %dh %dm", days, hours, minutes)
        } else if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }

    func formatHour(_ decimalHour: Double) -> String {
        let h = Int(decimalHour) % 24
        let m = Int((decimalHour.truncatingRemainder(dividingBy: 1)) * 60)
        return String(format: "%d:%02d", h, m)
    }

    deinit {
        timer?.invalidate()
    }
}
