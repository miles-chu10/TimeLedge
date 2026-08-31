# Verification record

Verified 2026-08-30 on:

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

## Consolidation validation in progress

- The earlier prototype's unique visibility policy and window-coverage evidence were
  ported under TimeLedge names; duplicated formatter, display, settings, panel,
  and overlay implementations were not copied.
- New pure-policy tests cover automatic, fullscreen-only, always-visible,
  fail-closed, pointer-reveal, and window-coverage behavior.
- The local machine currently has Command Line Tools but not full Xcode, so the
  macOS GitHub Actions run is the authoritative build/test gate for this change.

## Static safety evidence

- `OverlayPanel` is non-activating, cannot become key/main, ignores mouse events,
  and uses documented Spaces/fullscreen collection behaviors.
- The final app source contains no networking, analytics, accessibility,
  screen-content capture, AppleScript, secret, password, or API-key path. The
  visibility monitor reads window metadata but not pixels.
- The `.floating` overlay remains below the real menu bar's system level, so the
  menu bar can cover it when visible.

## Manual-only remainder

The following require hardware/state changes that were not performed during the
automated run: external-display unplug/replug, Stage Manager, sleep/wake, camera
or microphone privacy-dot activation, multiple user locales/time zones, and a
matrix of third-party fullscreen apps. The automated native-fullscreen probe
establishes the requested core fullscreen behavior but does not guarantee every
protected or future macOS surface.
