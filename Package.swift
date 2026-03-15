// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudePromotionMonitor",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ClaudePromotionMonitor",
            path: "Sources"
        )
    ]
)
