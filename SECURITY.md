# Security and privacy

TimeLedge is local-only. It does not include networking, analytics, advertising,
update checks, crash uploads, accessibility access, or screen-content capture.
Automatic fullscreen detection reads only on-screen window owner, layer, alpha,
and bounds metadata through Core Graphics; it does not read window pixels and
does not request Screen Recording permission.

Launch at Login uses Apple's `SMAppService.mainApp` only after an explicit user
toggle. Preferences are stored in the app's `UserDefaults` domain.

Report security issues through GitHub private vulnerability reporting. Do not
open a public issue containing secrets, private screen content, or unredacted
system diagnostics.
