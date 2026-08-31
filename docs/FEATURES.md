# Feature contract

## Required parity behavior

| Capability | TimeLedge contract | Evidence gate |
| --- | --- | --- |
| Hidden menu bar | Automatic mode shows the clock without forcing menu-bar reveal | Policy tests plus manual hidden-menu-bar check |
| Fullscreen | Frontmost-window coverage may exclude the documented notch-safe top strip and still activates the overlay when `visibleFrame` remains unchanged | Policy/coverage tests plus manual Safari/QuickTime check |
| Built-in display | Built-in display is enabled by default | Unit test plus runtime settings list |
| Multiple displays | Connected displays are detected and enabled independently | Unit policy test plus hot-plug check |
| Format | 12/24-hour, seconds, date, weekday, and custom pattern | Formatter tests |
| Locale | Uses the current locale, calendar, and time zone | Fixed-locale formatter tests plus manual locale check |
| Style | System/Rounded/Mono design, weight, size, color, and opacity | Build plus settings inspection |
| Readability | Optional background per display with adjustable opacity | Store test plus runtime inspection |
| Privacy-dot margin | Default and wide right margins | Placement tests plus camera/mic indicator check |
| Window level | Over-apps and behind-apps choices | Static mapping review plus manual stacking check |
| Low friction | Click-through overlay and menu-bar recovery path | Static panel review plus click test |
| Persistence | Preferences and per-display choices survive relaunch | Store tests |
| Reveal safety | Moving the pointer into the top reveal band suppresses the overlay briefly | Policy test plus manual pointer check |

## Deliberate improvements

- TimeLedge supports every system locale that `DateFormatter` can render instead
  of limiting the UI to a fixed language list.
- It is free under MIT and contains no network or analytics path.
- External displays are opt-in so the requested MacBook built-in-display behavior
  is the safe default. A desktop Mac with no built-in display falls back to its
  first active screen.

## Out of scope for 0.1.0

- Dragging or arbitrary clock placement
- Timer, stopwatch, world clocks, calendar, or reminders
- Local font discovery
- App Store packaging, Developer ID signing, notarization, or auto-update
- Guaranteed display above protected system surfaces, lock/login screens, or
  DRM-protected video

Stage Manager is included in the manual compatibility matrix but is not claimed
as verified until that matrix passes on a live Mac.
