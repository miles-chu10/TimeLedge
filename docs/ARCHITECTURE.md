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

## Menu-bar item

TimeLedge shows exactly one clock, and the overlay is it. The system already
draws a clock while the menu bar is visible, so `StatusItemController` owns a
square `NSStatusItem` carrying identity and controls rather than a second time
readout: the app icon, or the `clock` SF Symbol as a template fallback when no
bundle icon is available. The configured `ClockFormatter` output stays on the
button's accessibility label, so VoiceOver still reads the time. A lightweight
one-second timer refreshes only that label, including while the menu is closed.
It reads current preferences, holds the button weakly, and is invalidated when
the controller stops or is released; menu and preference changes also refresh it. The status item uses an autosave name so user
positioning persists.

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

## Menu-bar band geometry

`placementBounds` is the menu-bar band itself — the strip the system menu bar
occupies at the very top of a display — and `OverlayPlacement.frame` centers the
clock inside it. That puts TimeLedge on the same line the system clock uses,
which is the whole point of the product; anchoring below the band's bottom edge
put the clock a full menu-bar height too low. Content taller than the band keeps
its measured height and chosen style, with its top constrained to the display
top after rounding; the excess extends downward instead of being clipped or
scaled. Content that fits retains normal band centering.

The band height comes from the best available source per display:

- notched displays use `NSScreen.auxiliaryTopRightArea`, which also keeps the
  clock to the right of the notch
- other displays use the gap the menu bar leaves at the top of `visibleFrame`,
  falling back to `NSStatusBar.system.thickness` only when nothing better has
  been observed

A fullscreen Space hides the menu bar, which collapses that gap to zero, so
`SystemDisplayProvider` caches the largest height it has seen per display and
reuses it once the bar is gone.

Drawing inside the band does not raise the window level: `.floating` stays the
ceiling, and the real menu bar still renders above the overlay if both are on
screen. Automatic mode removes the overlay whenever ordinary menu-bar or
fullscreen evidence is absent, so the two do not compete. Fullscreen coverage
uses a separate hardware-notch inset so a maximized window below an ordinary
visible menu bar cannot be mistaken for fullscreen. Coordinates remain in macOS
global point space, including negative external-display coordinates.

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
