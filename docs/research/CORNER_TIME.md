# Corner Time public feature study

Observed 2026-08-30 (America/Los_Angeles). This is a clean-room behavior study,
not a source-code or binary analysis.

## Sources

- [Corner Time product page](https://cornertime.app/en)
- [Corner Time Mac App Store listing](https://apps.apple.com/app/corner-time/id6746757189)
- [Official 55-second demo](https://www.youtube.com/watch?v=G5y380i2M58)
- Apple public catalog record for app ID `6746757189`

## Confirmed public behavior

| Area | Publicly observable behavior |
| --- | --- |
| Core | Native-like top-right clock for a hidden menu bar; `Over Apps` keeps it visible in fullscreen |
| Format | 12/24-hour, seconds, date, weekday, and custom `DateFormatter` pattern |
| Style | SF Pro, SF Mono, SF Rounded; weight, size, adaptive/white/black color, and font opacity |
| Placement | Fixed to the system-like time position; arbitrary repositioning was not supported publicly |
| Margin | Default or wide right margin to avoid the privacy indicator dot |
| Background | Optional readable background, configurable by display, with a rounded style shown publicly |
| Displays | Automatic display discovery and independent enable switches; public FAQ says available since 1.2.5 |
| Windowing | Preference chooses over or under other app windows |
| Locale | Date/time follows the system language; ten languages were listed on the site |
| Compatibility | Product and catalog require macOS 13.0 or later; FAQ says notched and non-notched Macs work |
| Energy | Site describes low energy impact, but no public measurement methodology was found |

The official demo shows a single settings window with live preview and three
sections: **Format**, **Style**, and **General**. General includes display
switches and window level. The public site says there is no public API to remove
the menu-bar reveal delay.

## Current catalog facts

- Version: 1.3.1
- Current-version date: 2026-07-24
- Price: USD $2.99
- Size: 558,719 bytes in the Apple catalog
- Seller: Antidull LLC
- Current release note: customizable font opacity
- Category: Utilities

The product page's press block still reported a 2026-06-05 last update while
Apple's catalog reported 2026-07-24. TimeLedge treats Apple catalog metadata as
the current release record and the website block as stale.

## Public limitations and unknowns

- Public FAQ said arbitrary repositioning was not yet supported.
- The app works without a notch, but the product page says the notched layout is
  the best fit.
- The refund path is not a separate trial.
- The exact private window implementation, Stage Manager behavior, protected
  video behavior, login-item support, persistence schema, and measured energy
  impact were not publicly established.
- Marketing claims about future macOS beta compatibility are not implementation
  requirements for this clean-room project.

No Corner Time app bundle, source, icon, press-kit asset, or proprietary text is
included in TimeLedge.
