import SwiftUI

@main
struct ClaudePromotionMonitorApp: App {
    @StateObject private var timeManager = TimeManager()

    var body: some Scene {
        MenuBarExtra {
            StatusView(timeManager: timeManager)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: timeManager.menuBarIcon)
                if !timeManager.menuBarText.isEmpty {
                    Text(timeManager.menuBarText)
                        .font(.system(.body, weight: .semibold))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
