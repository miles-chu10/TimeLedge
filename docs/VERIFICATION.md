# Verification record

Prior baseline verified 2026-08-30 on:

- macOS 27.0 (26A5421a), Apple silicon
- Xcode 27.0 (27A5228h)
- Apple Swift 6.4
- Package deployment target: macOS 13.0

## Prior baseline passed before consolidation

- The prior manifest contained the core library, executable, test target, and
  macOS 13.0 deployment declaration.
- `swift-format lint` passed for `Package.swift`, sources, and tests.
- `swift test` passed 15 XCTest cases with zero failures.
- `script/build_and_run.sh --build` created `dist/TimeLedge.app`.
- `plutil -lint` passed and the bundle reports `LSUIElement=true`,
  `LSMinimumSystemVersion=13.0`, and `NSPrincipalClass=NSApplication`.
- Ad-hoc `codesign --verify --deep --strict` passed.
- `--verify` launched the bundle and confirmed the `TimeLedge` process.
- App-owned Retina snapshots rendered Format, Style, General, and the overlay.
  Visual inspection found no clipping, overflow, duplicate controls, or stray
  window.
- Core Graphics window inventory found exactly one 520-point settings window and
  one 114×16-point built-in-display overlay after the lifecycle fix.
- A separate temporary AppKit app entered a real native fullscreen Space. While
  fullscreen, Core Graphics reported exactly one on-screen TimeLedge overlay at
  `NSWindow.Level.floating`. The helper exited and restored the desktop.
- The live display list showed **Built-in Retina Display** enabled and the
  external **ASUS VG249** disabled by default.

## Final 0.1.0 validation passed

Final CI and live fullscreen validation completed 2026-08-31.

- The earlier prototype's unique visibility policy and window-coverage evidence were
  ported under TimeLedge names; duplicated formatter, display, settings, panel,
  and overlay implementations were not copied.
- New pure-policy tests cover automatic, fullscreen-only, always-visible,
  fail-closed, pointer-reveal, and window-coverage behavior.
- Dedicated transition tests prove that an ordinary maximize without a Spaces
  change fails closed, maximizing before a later Space switch also fails
  closed, a tightly correlated windowed-to-fullscreen transition is accepted,
  verification survives leaving and returning to that Space, and same-window
  Space changes or windowed geometry clear stale trust.
- GitHub Actions CI run
  [`33409556063`](https://github.com/miles-chu10/TimeLedge/actions/runs/33409556063)
  passed on macOS for commit `dd47f60`: all 48 XCTest cases passed, the
  release-optimized app bundle built, app and privacy plist validation passed,
  ad-hoc `codesign --verify --deep --strict` passed, and the downloadable
  artifact uploaded.
- The CI runner used macOS SDK 26.5 and Apple Swift 6.3.3; the package continues
  to declare macOS 13.0 as its deployment target.
- The exact CI artifact launched locally from the canonical
  `/Users/mileschu/code/apps/TimeLedge/dist/TimeLedge.app` path. With Automatic
  mode and the ordinary menu bar visible, Core Graphics reported zero TimeLedge
  overlay windows.
- A separate AppKit helper remained frontmost while its ordinary window entered
  a native fullscreen Space. The final artifact produced exactly one on-screen
  TimeLedge overlay at `.floating`,
  `{X:1369,Y:35,W:131,H:16}`, and the rendered screenshot showed the clock at
  the top-right below the hidden 32-point system strip.
- Moving the pointer into the top reveal band reduced the on-screen overlay
  count to zero; exiting fullscreen also left zero overlay windows.
- The bundled privacy manifest declares local-only UserDefaults access with
  Apple's `CA92.1` required reason and declares no tracking or collected data.
- The local machine currently has Command Line Tools but not full Xcode; the
  macOS GitHub Actions run is therefore the authoritative native build evidence.

## Unreleased menu-bar detection rework

The 0.1.0 fullscreen evidence model was reported broken on a live Mac: in a
fullscreen Chrome Space the top-right corner was empty, and the menu-bar item
duplicated the system clock. Re-verification of this change is therefore
pending, and the 0.1.0 fullscreen evidence above no longer describes the
shipping code.

- Root cause of the empty corner: `FullscreenTransitionDetector` only trusted
  full-display coverage that it had watched change during a Spaces transition,
  and it revoked that trust when the same window stayed frontmost across a Space
  change. A Space that was already open at launch was never verified, and a
  verified Space that was left and re-entered could not be verified again,
  because re-verification required first observing the window not covering the
  display.
- The detector and its tests were removed. `MenuBarPresenceTracker` plus
  `MenuBarWindowProbe` now observe whether the window server draws the menu bar
  on each display, using public `CGWindowListCopyWindowInfo` metadata (layer,
  bounds, alpha) and no window contents.
- The tracker self-calibrates per display and reports *unknown* until it has
  actually seen that display's menu bar, so menu-bar geometry and full-display
  coverage remain the fallback evidence.
- The overlay now takes over the strip the menu bar vacated instead of rendering
  below it, and the menu-bar item is icon-only unless the user opts in.

macOS CI passed on commit `6aa458c`
([`33459663780`](https://github.com/miles-chu10/TimeLedge/actions/runs/33459663780)):
60 XCTest cases with zero failures, release-optimized bundle built, app and
privacy plists linted, and ad-hoc `codesign --verify --deep --strict` passed.
The matching push run
([`33459641275`](https://github.com/miles-chu10/TimeLedge/actions/runs/33459641275))
uploaded the `TimeLedge-macOS` artifact for local testing.

Still required before release, because no Linux container can produce it:

- Live matrix on a Mac: a fullscreen Space opened before TimeLedge launched, a
  Space left and re-entered, pointer reveal, an ordinary maximized window, an
  external display, and the `--diagnose` evidence table on the reporting
  machine.

## Static safety evidence

- `OverlayPanel` is non-activating, cannot become key/main, ignores mouse events,
  and uses documented Spaces/fullscreen collection behaviors.
- The final app source contains no networking, analytics, accessibility,
  screen-content capture, AppleScript, secret, password, or API-key path. The
  visibility monitor reads window metadata but not pixels.
- The `.floating` overlay remains below the real menu bar's system level, so the
  menu bar can cover it when visible.
- The menu-bar probe reads window metadata only. It requests no new entitlement,
  permission, or private API, and it never captures screen content.

## Manual-only remainder

The following require hardware/state changes that were not performed during the
automated run: external-display unplug/replug, Stage Manager, sleep/wake, camera
or microphone privacy-dot activation, multiple user locales/time zones, and a
matrix of third-party fullscreen apps. The live native-fullscreen probe
establishes the requested core fullscreen behavior but does not guarantee every
protected or future macOS surface.
