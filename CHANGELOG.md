# Changelog

## Unreleased

### Fixed

- The clock no longer stays hidden in fullscreen. Visibility is now decided by
  directly observing whether the system menu bar is drawn on each display,
  instead of inferring fullscreen from Spaces-change-correlated window
  transitions. The old inference could not verify a fullscreen Space that was
  already open when TimeLedge launched, and revoked its verification when a
  Space was left and re-entered, leaving nothing in the top-right corner for the
  rest of the session.
- The menu-bar item no longer duplicates the system clock. It is an icon by
  default; the formatted text clock is opt-in via **Show Time in Menu Bar** in
  the menu or Settings.
- While the menu bar is hidden the overlay is centered in the strip the menu bar
  vacated instead of below it, so it no longer overlaps the fullscreen app's own
  content.
- Preferences written by an older build no longer reset to defaults when a new
  preference key is added.

### Added

- `TimeLedge --diagnose` prints the per-display visibility evidence and exits.

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
