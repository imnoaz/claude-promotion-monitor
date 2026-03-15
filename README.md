# Claude Promotion Monitor

A macOS menubar app that tracks Claude's [March 2026 usage promotion](https://support.claude.com/en/articles/14063676-claude-march-2026-usage-promotion) status in real-time.

<img src="docs/screenshot.png" width="340" alt="Claude Promotion Monitor screenshot">

## What is this?

From March 13 through March 27, 2026, Claude's usage is **doubled during off-peak hours** (outside 8 AM–2 PM ET). The bonus usage doesn't count toward weekly limits.

This app sits in your menubar and shows:

- **Current status** — Peak (1×) or Off-peak (2×) at a glance
- **24-hour clock** — Visual representation of peak/off-peak periods in your local timezone with a live needle
- **Countdown timer** — Time remaining until the next peak/off-peak switch
- **Promotion status** — Whether the promotion is active and how much time is left

## Eligible Plans

Free / Pro / Max / Team (Enterprise is excluded)

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build & Run

```bash
git clone https://github.com/imnoaz/claude-promotion-monitor.git
cd claude-promotion-monitor
chmod +x build.sh
./build.sh
open "Claude Promotion Monitor.app"
```

## Install

```bash
cp -r "Claude Promotion Monitor.app" /Applications/
```

## Customization

Promotion dates and peak hours are defined in `Sources/TimeManager.swift`:

```swift
// Peak hours (ET)
let peakStartHour = 8
let peakEndHour = 14

// Promotion period (ET)
startComponents.year = 2026
startComponents.month = 3
startComponents.day = 13
// ...
endComponents.day = 28
```

Edit these values and rebuild to adapt the app to a different promotion period.

## Tech Stack

- Swift / SwiftUI
- `MenuBarExtra` with `.window` style
- Custom `Canvas`-based 24-hour clock
- Swift Package Manager

## License

MIT
