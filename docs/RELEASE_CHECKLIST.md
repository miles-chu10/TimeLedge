# Release and acceptance checklist

## Automated gate

Run from the project root:

```sh
/usr/bin/xcrun swift package dump-package
./script/codex-test.sh
./script/codex-build.sh
/usr/bin/plutil -lint dist/TimeLedge.app/Contents/Info.plist
/usr/bin/codesign --verify --deep --strict dist/TimeLedge.app
```

Confirm the manifest declares `TimeLedgeCore`, `TimeLedge`, `TimeLedgeCoreTests`,
`TimeLedgeAppTests`, and macOS 13.0. Confirm the plist contains `LSUIElement=true`,
`NSPrincipalClass`, the stable bundle identifier, and `LSMinimumSystemVersion=13.0`.

## Live macOS matrix

- [ ] Built-in display is enabled and external displays are disabled on first run
- [ ] Clock ignores clicks and the menu-bar icon remains the recovery path
- [ ] Hidden menu bar reveals over the clock without an unreadable collision
- [ ] Automatic mode shows for hidden-menu-bar and fullscreen evidence
- [ ] Fullscreen Only mode fails closed without both hidden-menu-bar and
      frontmost full-display evidence
- [ ] Always mode preserves the enabled-display overlay behavior
- [ ] Safari native fullscreen keeps the clock visible
- [ ] QuickTime or another native fullscreen app keeps the clock visible
- [ ] A new Space and Space switch keep exactly one clock per enabled display
- [ ] Mission Control does not create stray or duplicated clock windows
- [ ] Stage Manager has no duplicated, focus-stealing, or trapped clock window
- [ ] External display opt-in, unplug, and replug update the panel set correctly
- [ ] Notched built-in display keeps the text right of the notch and directly
      below the hidden system strip
- [ ] Wide margin avoids the camera/microphone privacy indicator
- [ ] Light/dark appearance and readable background remain legible
- [ ] 12/24-hour, seconds, custom pattern, locale, and time-zone changes update
- [ ] Sleep/wake restores the clock without duplication
- [ ] Settings can become key even though overlay panels never do
- [ ] Quit removes all panels and the menu-bar item

## Distribution gates

Public source publication is authorized. The CI artifact is release-optimized
but ad-hoc signed and retained for seven days; it is not a durable public
release. Developer ID signing, hardened runtime, notarization, installer
creation, deployment, and App Store submission remain unperformed and require
separate authorization.

Before Mac App Store submission, also validate App Sandbox compatibility and
prepare App Store Connect metadata, 16:10 Mac screenshots, support and privacy
URLs, distribution signing, provisioning, and review notes. The repository's
current public references are:

- Privacy: <https://github.com/miles-chu10/TimeLedge/blob/main/PRIVACY.md>
- Support: <https://github.com/miles-chu10/TimeLedge/issues>
