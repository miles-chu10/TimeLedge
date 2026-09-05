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

## Menu-bar clock

`StatusItemController` owns an `NSStatusItem` that is an icon by default. macOS
already draws a clock in the menu bar, so a second formatted clock next to it is
duplication; the status item is the control surface (Show Clock, Show Time in
Menu Bar, Settings, Launch at Login, Quit) rather than a second clock. Users who
do want the text can opt in with **Show Time in Menu Bar**, which renders the
same `ClockFormatter` output as the overlay in a variable-length item. The
status item uses an autosave name so user positioning persists.

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
the right of a notch and normalizes that area to the physical display edges. The
clock is then laid out in one of two bands:

- menu bar off screen: centered inside the strip the menu bar vacated, which is
  where a menu-bar clock belongs and keeps the overlay off the app's content
- menu bar on screen: anchored below the strip, because the documented
  `.floating` level renders under the real menu bar

On displays without a notch, the provider remembers the last visible menu-bar
height from `visibleFrame` and retains it while fullscreen hides the bar. Space
changes refresh the stored display descriptors so newly learned geometry is used
on subsequent fullscreen entries. Oversized clock content retains its measured
height and uses the existing top anchor; rounding cannot move its top edge above
the display or enlarge its width past the available band.

Fullscreen coverage uses a separate hardware-notch inset so a maximized window
below an ordinary visible menu bar cannot be mistaken for fullscreen. Coordinates
remain in macOS global point space, including negative external-display
coordinates.

## Visibility pipeline

`FullscreenVisibilityMonitor` observes active Spaces, app activation,
session/sleep state, and display changes, with a 250 ms poll for window geometry
changes that have no reliable notification. It gathers three independent pieces
of evidence per display and runs them through the pure `ClockVisibilityPolicy`:

1. **Menu-bar window presence.** `MenuBarWindowProbe` lists on-screen windows in
   the public main-menu window level, keeps only the window server's own menu
   bar -- that level is public, so any process can put a window there -- and
   matches them to display top edges;
   `MenuBarPresenceTracker` turns that into "the menu bar is (not) drawn on this
   display". This is a direct observation of the condition the app exists for,
   so it works on launch inside a fullscreen Space, across Space switches, and
   with the system auto-hide setting. The tracker self-calibrates: a display
   reports *hidden* only after its menu bar has actually been seen once, so an
   unexpected window-server layout reports *unknown* and the other evidence
   decides. A window list that cannot be read at all is distinct from an empty
   one: the tracker repeats its last answer rather than claiming every menu bar
   just disappeared. A menu bar the probe positively sees is authoritative and
   geometry cannot overrule it, because with the system set to auto-hide the
   menu bar `visibleFrame` reports full height either way.
2. **Menu-bar geometry.** `NSScreen.frame` versus `visibleFrame`.
3. **Frontmost-window coverage.** Notch-safe full-display coverage of the
   frontmost application's windows.

An earlier design inferred fullscreen from Spaces-change-correlated coverage
transitions. That produced false negatives that made the clock disappear for the
rest of a session -- a Space entered before launch, or left and re-entered, was
never re-verified -- so it was replaced by the direct observation above.

Automatic mode shows an enabled display when the menu bar is not on screen by
any of that evidence. `Fullscreen Only` additionally requires full-display
coverage. `Always` preserves the persistent-overlay behavior while the session
is active. A menu bar the probe positively sees, with no geometry evidence to
the contrary, suppresses the overlay in both automatic modes so the clock is
never a duplicate of the system clock. Session inactivity, a missing display,
and the global Show Clock toggle fail closed, and automatic modes also suppress
the overlay during pointer-based menu-bar reveal.

`TimeLedge --diagnose` prints that evidence table for every display and exits,
so a machine-specific misdetection can be reported without guesswork.

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
