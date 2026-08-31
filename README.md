# TimeLedge

TimeLedge is a free, open-source macOS clock that stays visible when the menu
bar is hidden and in fullscreen Spaces. It is a clean-room implementation built
with SwiftUI and AppKit and licensed under MIT.

## What works

- Click-through, non-activating clock overlay above fullscreen apps
- Automatic visibility when the menu bar is hidden, with stricter
  fullscreen-only and always-visible modes
- Built-in Mac display enabled by default; external displays are opt-in
- Automatic display discovery and per-display readable backgrounds
- 12/24-hour time, seconds, date, weekday, and custom DateFormatter patterns
- System-locale and system-time-zone formatting
- SF Pro, SF Rounded, and SF Mono designs; weight, size, color, and opacity
- Default or wide right margin for the camera/microphone privacy indicator
- Menu-bar controls, a native settings window, preference persistence, and
  opt-in Launch at Login
- No network requests, analytics, ads, accessibility permission, or screen
  recording permission

## Requirements

- macOS 13 or later
- Full Xcode with Swift 5.7 or later

## Build, test, and run

```sh
./script/codex-test.sh
./script/codex-build.sh
./script/build_and_run.sh --verify
```

The script creates `dist/TimeLedge.app`, ad-hoc signs it for local testing, and
launches the bundle as a menu-bar app. It does not copy the app into
`/Applications`, change Login Items, or publish anything. Launch at Login is
changed only when the user toggles it inside TimeLedge.

## Use

1. Launch `dist/TimeLedge.app`.
2. Look for the clock icon in the menu bar.
3. Open **Settings…** to configure format, style, displays, and window level.
4. Keep **Window level → Over Apps** selected for fullscreen visibility.

The overlay ignores mouse events. Use the menu-bar icon to show, hide, configure,
or quit TimeLedge.

## Codex Cloud

The repository includes `script/codex-cloud-setup.sh` and a matching maintenance
script for the Codex Cloud environment. Cloud can inspect the package, resolve
dependencies, edit code, and open pull requests. Its Linux container does not
include Xcode or AppKit, so native build and test evidence comes from the macOS
GitHub Actions workflow or a local Mac with full Xcode.

## Verification status

Automated tests cover formatting, persistence, display-default policy, and
top-right geometry. The build script validates the app bundle and running
process. Fullscreen Spaces, Mission Control, Stage Manager, display hot-plug,
and notch/menu-bar interactions still require the manual matrix in
[`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) because AppKit window
collection behavior cannot be proven by unit tests.

## Research and clean-room boundary

The product behavior and alternatives were researched from public pages,
metadata, demos, and repository documentation. No Corner Time binary, source,
or asset is included. The consolidated visibility code was generated within the
same user-owned clean-room project. See:

- [`docs/research/CORNER_TIME.md`](docs/research/CORNER_TIME.md)
- [`docs/research/ALTERNATIVES.md`](docs/research/ALTERNATIVES.md)
- [`docs/FEATURES.md`](docs/FEATURES.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/VERIFICATION.md`](docs/VERIFICATION.md)

TimeLedge is not affiliated with Corner Time, Antidull LLC, or any alternative
project listed in the research notes.
