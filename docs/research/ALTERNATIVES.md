# Open-source and source-available alternatives

Repository state checked 2026-08-30 through GitHub's public repository data and
the listed project documentation. Time-sensitive fields should be refreshed
before any future fork decision.

| Project | License found | Public fit | Decision note |
| --- | --- | --- | --- |
| [itsnaveenk/clock-overlay](https://github.com/itsnaveenk/clock-overlay) | MIT | Fullscreen/all-Spaces panel, drag, format/style, click-through, login item; targets macOS 14 | Closest reusable base, but lacks macOS 13 and the verified per-display/native-position contract |
| [jessicayang-lab/CornerClock.Clone](https://github.com/jessicayang-lab/CornerClock.Clone) | No repository LICENSE file found | Claims near-parity hidden-menu-bar behavior | README says MIT, but repository metadata and root tree exposed no license file; do not reuse code without a valid grant |
| [yousabinsadeque/FloatingClockOverlay](https://github.com/yousabinsadeque/FloatingClockOverlay) | Custom non-commercial source-available license | Rich themes, clock/timer/stopwatch, fullscreen panel | Not open source under the OSI definition and unsuitable for an unrestricted MIT project |
| [eveoh354/OffTick](https://github.com/eveoh354/OffTick) | MIT | Floating workday clock/countdown with locale and launch controls | Broader work-tracking product; not a native-like fixed corner clock |
| [thomplth/meridian](https://github.com/thomplth/meridian) | No license found | Bare-bones floating clock | Too small and unlicensed for safe reuse |
| [mattiarossini/MinimalClock](https://github.com/mattiarossini/MinimalClock) | MIT | Clock screen saver | Different lifecycle; not an overlay over fullscreen apps |

## Build-versus-adopt decision

TimeLedge uses a clean-room build. The MIT `clock-overlay` project proves that a
similar free utility already exists and should be brought to a user's attention,
but adopting it would still require substantial changes for the requested
built-in-display default, per-display controls, native fixed placement,
privacy-dot margin, locale contract, macOS 13 deployment, tests, and reproducible
Codex run workflow.

No alternative code, asset, app bundle, or build artifact was copied into this
repository.
