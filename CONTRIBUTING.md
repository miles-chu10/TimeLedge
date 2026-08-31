# Contributing

1. Keep the implementation clean-room: do not copy proprietary app code,
   screenshots, icons, text, or other assets.
2. Make changes in focused files and preserve macOS 13 compatibility.
3. Run `./script/codex-test.sh` and `./script/codex-build.sh` with full Xcode.
4. Add or update tests for pure formatting, persistence, and geometry behavior.
5. Record manual-only window behavior in `docs/RELEASE_CHECKLIST.md`.
6. Treat Codex Cloud as an editing environment; use macOS CI for AppKit proof.

Bug reports should include the macOS version, Mac/display model, menu-bar mode,
fullscreen app, and exact reproduction steps. Do not include personal screen
content or system logs unless they have been reviewed and redacted.
