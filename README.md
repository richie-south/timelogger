# TimeLogger

A lightweight macOS menu bar app for time logging, built with SwiftUI.

## Features

- **Menu bar app** — lives in your taskbar, no dock icon
- **Start/Stop timer** — type an activity name and hit Start (or press Enter)
- **Activity log** — see all logged entries with formatted durations
- **Export to JSON** — save your time entries as a JSON file with name and minutes
- **Clear all** — wipe entries when starting a new day
- **Running total** — see total logged time in the header

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+

## Build & Run

1. Open `TimeLogger/TimeLogger.xcodeproj` in Xcode
2. Select the **TimeLogger** scheme
3. Press **Cmd+R** to build and run

The app will appear as a clock icon in your menu bar.

## JSON Export Format

```json
[
  {
    "name": "Code review",
    "minutes": 30.5,
    "formatted": "30m 30s"
  },
  {
    "name": "Feature development",
    "minutes": 90.0,
    "formatted": "1h 30m 00s"
  }
]
```
