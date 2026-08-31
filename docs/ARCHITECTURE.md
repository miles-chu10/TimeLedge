# Architecture

## Shape

```text
TimeLedgeCore
├── ClockPreferences.swift   Codable, platform-neutral settings
├── ClockFormatter.swift     locale-aware and custom formatting
├── ClockVisibility.swift    pure automatic/fullscreen/always policy
├── WindowCoverage.swift     pure display-coverage evidence
└── OverlayPlacement.swift   pure top-right geometry

TimeLedge
├── App/                     app entry point and lifecycle
├── Models/                  live display descriptors
├── Stores/                  UserDefaults-backed observable state
├── Services/                display, panel, status item, login item
├── Support/                 SwiftUI/AppKit mappings
└── Views/                   overlay and settings SwiftUI views
```

## Window contract

Each enabled display owns one borderless, non-activating `NSPanel`:

- transparent and shadowless
- `ignoresMouseEvents = true`
- never key or main
- does not hide when TimeLedge deactivates
- joins all Spaces and participates as a fullscreen auxiliary window
- stays stationary and out of the normal window cycle

`Over Apps` uses the documented `.floating` level. That is high enough for app
content while remaining below the system menu bar when it reappears. `Behind
Apps` uses `.normal` and orders the panel behind normal windows. The app
intentionally avoids status-bar/screen-saver levels and private window APIs.

The placement calculator uses `NSScreen.auxiliaryTopRightArea` when a notched
display provides it; otherwise it uses the screen frame. Coordinates remain in
macOS global point space, including negative external-display coordinates.

## Visibility pipeline

`FullscreenVisibilityMonitor` observes active Spaces, app activation,
session/sleep state, and display changes, with a 250 ms poll for window geometry
changes that have no reliable notification. It combines menu-bar geometry,
frontmost layer-0 window coverage, and a short pointer-reveal hold through the
pure `ClockVisibilityPolicy`.

The default mode shows an enabled display when its menu bar is hidden or the
frontmost app owns a layer-0 window covering the display. `Fullscreen Only`
requires that full-display window evidence. `Always`
preserves the original persistent-overlay behavior. Session inactivity, a
missing display, and the global Show Clock toggle fail closed. Automatic modes
also suppress the overlay during pointer-based menu-bar reveal.

## Display lifecycle

`SystemDisplayProvider` maps each `NSScreen` to its Core Graphics display ID and
UUID. The coordinator observes:

- `NSApplication.didChangeScreenParametersNotification`
- `NSWorkspace.activeSpaceDidChangeNotification`
- `NSWorkspace.didWakeNotification`

It removes stale panels, rebuilds newly connected displays, and reapplies frame,
content, level, and order after each transition.

## State and privacy

The observable store persists Codable preferences and display choices to
`UserDefaults`. Formatting uses `Locale.autoupdatingCurrent`,
`TimeZone.autoupdatingCurrent`, and `Calendar.autoupdatingCurrent`.

There are no network clients, external processes in the app, telemetry hooks,
pixel-capture paths, accessibility APIs, or credential paths. The visibility
monitor reads Core Graphics window metadata only. The build script is project
tooling and is not executed by the running app.

## Known verification boundary

AppKit collection behavior expresses a request to the window server. Unit tests
cannot prove visibility above every fullscreen application or future macOS
release. The release checklist therefore separates automated evidence from the
required live fullscreen/Spaces/display matrix.
