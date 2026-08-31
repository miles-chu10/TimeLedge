# Changelog

## Unreleased

- Fixed the overlay rendering a full menu-bar height below the menu bar.
  `DisplayDescriptor.placementBounds` returned the area *under* the band rather
  than the band itself, so the clock was anchored downward from the band's bottom
  edge. It is now centred inside the band, on the system clock's line.
- Menu-bar band height is now taken from the gap the menu bar leaves at the top
  of `visibleFrame` on displays without a notch, instead of
  `NSStatusBar.system.thickness`, and the largest observed height is cached per
  display so a fullscreen Space hiding the menu bar cannot collapse it.
- The menu-bar item now shows the app icon rather than a second clock. The
  formatted time stays on its accessibility label, and the item no longer runs a
  per-second timer.
- Fixed an unreachable guard in `StatusItemController.menuBarTitle`: it tested
  the rendered title for emptiness, which `ClockFormatter` never produces. It now
  trims whitespace first, so a custom pattern that renders blank falls back to
  standard time.

## 0.1.0 - 2026-08-30

- Initial clean-room macOS 13+ implementation
- Built-in-display-first fullscreen clock overlay
- Per-display enablement and readable backgrounds
- Locale-aware and custom date/time formatting
- Font, color, size, opacity, margin, and window-level controls
- Menu-bar settings and opt-in Launch at Login
- SwiftPM app-bundle run workflow and automated test suite
- Consolidated automatic hidden-menu-bar/fullscreen detection from the earlier
  prototype under the canonical TimeLedge name
- Added public-repository CI and Codex Cloud setup/maintenance scaffolding
- Added the original TimeLedge app icon, bundle icon metadata, privacy manifest,
  and downloadable CI app artifact
