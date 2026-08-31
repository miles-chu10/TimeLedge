# TimeLedge

TimeLedge is a SwiftPM-only macOS 13+ menu-bar utility built with SwiftUI and
AppKit. Keep platform-neutral policy in `TimeLedgeCore` and Apple-framework
integration in the `TimeLedge` executable target.

## Commands

```sh
./script/codex-test.sh
./script/codex-build.sh
```

The full app requires Xcode and a macOS SDK. Codex Cloud can inspect and edit the
repository, but macOS build and test evidence must come from a Mac or macOS CI.

Do not add networking, telemetry, private APIs, copied Corner Time assets, or
permission-gated screen capture.
