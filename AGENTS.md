# TimeLedge contributor instructions

- TimeLedge is SwiftPM-only. Do not add an Xcode project or use `xcodebuild`.
- Use `/usr/bin/xcrun swift` so builds use the active Xcode toolchain rather than
  an unrelated Swift toolchain earlier on `PATH`.
- Preserve macOS 13 deployment compatibility and the clean-room boundary.
- Keep Foundation-only behavior in `TimeLedgeCore`; keep AppKit/SwiftUI edges in
  the `TimeLedge` executable target.
- Do not add networking, telemetry, permissions, private APIs, or undocumented
  window levels.
- Run the complete test suite, app-bundle build, plist lint, and manual window
  matrix proportionate to the changed behavior.
- Codex Cloud uses Linux and cannot validate AppKit. Keep manifest/dependency
  setup cloud-safe, and require local macOS or macOS CI for build/test evidence.

## Code Review Rules

- Treat any change that makes automatic visibility show while the system menu
  bar is drawn on that display, ignores session inactivity, or bypasses
  automatic-mode pointer-reveal suppression as a P1 regression.
- Treat any change that makes the clock stay hidden while the menu bar is off
  screen -- a fullscreen Space entered before launch, or left and re-entered --
  as an equally serious P1 regression. Both directions matter: the app exists to
  replace the menu-bar clock exactly when the menu bar is gone.
- Menu-bar detection is a direct observation (`MenuBarPresenceTracker`), not an
  inference from Spaces transitions. Do not reintroduce trust that a window has
  to earn and can silently lose for the rest of a session.
- Treat networking, telemetry, private window APIs, permission-gated screen
  capture, or copied proprietary Corner Time material as P1.
- Keep `.floating` as the highest supported overlay level; do not use status-bar,
  screen-saver, or undocumented levels.
