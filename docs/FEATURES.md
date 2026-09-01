# Feature contract

## Required parity behavior

| Capability | TimeLedge contract | Evidence gate |
| --- | --- | --- |
| Hidden menu bar | Automatic mode shows the clock whenever the system menu bar is not drawn on the display, by direct window observation or per-display geometry | Menu-bar presence and policy tests plus manual hidden-menu-bar check |
| Fullscreen | The vacated menu bar plus notch-safe full-display window coverage identifies fullscreen without Accessibility permission, including Spaces entered before launch | Presence/coverage tests plus manual Safari/QuickTime check |
| Built-in display | Built-in display is enabled by default | Unit test plus runtime settings list |
| Multiple displays | Connected displays are detected and enabled independently | Unit policy test plus hot-plug check |
| Format | 12/24-hour, seconds, date, weekday, and custom pattern | Formatter tests |
| Locale | Uses the current locale, calendar, and time zone | Fixed-locale formatter tests plus manual locale check |
| Style | System/Rounded/Mono design, weight, size, color, and opacity | Build plus settings inspection |
| Readability | Optional background per display with adjustable opacity | Store test plus runtime inspection |
| Privacy-dot margin | Default and wide right margins | Placement tests plus camera/mic indicator check |
| Window level | Over-apps and behind-apps choices | Static mapping review plus manual stacking check |
| Visible menu bar | An icon-only `NSStatusItem` carries the controls; the formatted text clock is opt-in so it never duplicates the system clock | App test plus live menu-bar inspection |
| Low friction | Click-through overlay and a menu-bar control item | Static panel review plus click test |
| Persistence | Preferences and per-display choices survive relaunch | Store tests |
| Reveal safety | Moving the pointer into the top reveal band suppresses the overlay briefly | Policy test plus manual pointer check |

## Deliberate improvements

- TimeLedge supports every system locale that `DateFormatter` can render instead
  of limiting the UI to a fixed language list.
- It is free under MIT and contains no network or analytics path.
- On a Mac with a built-in display, extra monitors are opt-in so the requested
  built-in-display behavior is the safe default. A desktop Mac has no built-in
  display, so every display it has is enabled by default.

## Out of scope for 0.1.0

- Dragging or arbitrary clock placement
- Timer, stopwatch, world clocks, calendar, or reminders
- Local font discovery
- App Store packaging, Developer ID signing, notarization, or auto-update
- Guaranteed display above protected system surfaces, lock/login screens, or
  DRM-protected video

Stage Manager is included in the manual compatibility matrix but is not claimed
as verified until that matrix passes on a live Mac.
