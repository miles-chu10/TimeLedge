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
- joins all Spaces and other applications' fullscreen sets as an auxiliary
  window
- stays stationary and out of the normal window cycle

`Over Apps` uses the documented `.floating` level. That is high enough for app
content while remaining below the system menu bar when it reappears. `Behind
Apps` uses `.normal` and orders the panel behind normal windows. The app
intentionally avoids status-bar/screen-saver levels and private window APIs.

The display provider uses `NSScreen.auxiliaryTopRightArea` to keep the clock to
the right of a notch, normalizes that area to the physical display edges, and
anchors the clock immediately below the hidden system strip. This keeps the
documented `.floating` level below protected menu-bar surfaces while Automatic
mode removes the overlay whenever ordinary menu-bar/fullscreen evidence is
absent. Coordinates remain in macOS global point space, including negative
external-display coordinates.

## Visibility pipeline

`FullscreenVisibilityMonitor` observes active Spaces, app activation,
session/sleep state, and display changes, with a 250 ms poll for window geometry
changes that have no reliable notification. A pure transition detector trusts
notch-safe frontmost-window coverage only when the same window was recently
noncovering and then changed during a Spaces transition. The monitor combines
that verified evidence with menu-bar geometry and a short pointer-reveal hold
through the pure `ClockVisibilityPolicy`.

The default mode shows an enabled display when its menu bar is hidden or a
verified fullscreen transition covers it. `Fullscreen Only` requires the
verified transition. `Always` preserves the original persistent-overlay
behavior while the session is active.
Session inactivity, a
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
