import AppKit
import TimeLedgeCore

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
  private let store: PreferencesStore
  private let statusItem: NSStatusItem
  private let onOpenSettings: () -> Void
  private let onSetLaunchAtLogin: (Bool) -> Void

  private lazy var showClockItem = NSMenuItem(
    title: "Show Clock",
    action: #selector(toggleClock),
    keyEquivalent: ""
  )
  private lazy var launchAtLoginItem = NSMenuItem(
    title: "Launch at Login",
    action: #selector(toggleLaunchAtLogin),
    keyEquivalent: ""
  )

  init(
    store: PreferencesStore,
    onOpenSettings: @escaping () -> Void,
    onSetLaunchAtLogin: @escaping (Bool) -> Void
  ) {
    self.store = store
    self.onOpenSettings = onOpenSettings
    self.onSetLaunchAtLogin = onSetLaunchAtLogin
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    super.init()

    statusItem.autosaveName = "com.mileschu.TimeLedge.clock"
    statusItem.isVisible = true
    statusItem.button?.toolTip = "TimeLedge"
    refresh()

    let menu = NSMenu()
    menu.delegate = self
    showClockItem.target = self
    launchAtLoginItem.target = self
    menu.addItem(showClockItem)
    menu.addItem(NSMenuItem.separator())

    let settingsItem = NSMenuItem(
      title: "Settings…",
      action: #selector(openSettings),
      keyEquivalent: ","
    )
    settingsItem.target = self
    menu.addItem(settingsItem)
    menu.addItem(launchAtLoginItem)
    menu.addItem(NSMenuItem.separator())

    let quitItem = NSMenuItem(
      title: "Quit TimeLedge",
      action: #selector(quit),
      keyEquivalent: "q"
    )
    quitItem.target = self
    menu.addItem(quitItem)
    statusItem.menu = menu
  }

  static func menuBarTitle(
    at date: Date,
    preferences: ClockPreferences,
    isClockVisible: Bool
  ) -> String? {
    guard isClockVisible else { return nil }
    let configuredTitle = ClockFormatter.string(from: date, preferences: preferences)
    // A custom pattern can render to nothing visible (for example a quoted run of
    // spaces). `ClockFormatter` only guards a blank *pattern*, so the rendered
    // result is checked here before it becomes an unreadable accessibility label.
    guard configuredTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return configuredTitle
    }
    var fallbackPreferences = preferences
    fallbackPreferences.customFormatEnabled = false
    fallbackPreferences.showDate = false
    fallbackPreferences.showWeekday = false
    return ClockFormatter.string(from: date, preferences: fallbackPreferences)
  }

  /// Menu-bar artwork for the status item.
  ///
  /// TimeLedge shows exactly one clock — the overlay — so the status item
  /// carries identity and the menu rather than a second time readout. The app
  /// icon is used when the bundle provides one; the SF Symbol keeps the item
  /// reachable in unit tests and unbundled runs.
  static func statusItemImage(appIcon: NSImage?) -> NSImage {
    let side: CGFloat = 18
    if let appIcon, appIcon.isValid {
      let sized = NSImage(size: NSSize(width: side, height: side), flipped: false) { rect in
        appIcon.draw(in: rect)
        return true
      }
      sized.isTemplate = false
      return sized
    }

    let fallback =
      NSImage(systemSymbolName: "clock", accessibilityDescription: "TimeLedge")
      ?? NSImage(size: NSSize(width: side, height: side))
    fallback.isTemplate = true
    return fallback
  }

  static func statusItemImage() -> NSImage {
    statusItemImage(appIcon: Bundle.main.image(forResource: "TimeLedge"))
  }

  func refresh() {
    guard let button = statusItem.button else { return }
    statusItem.length = NSStatusItem.squareLength
    button.title = ""
    button.image = Self.statusItemImage()
    button.imagePosition = .imageOnly

    if let title = Self.menuBarTitle(
      at: Date(),
      preferences: store.preferences,
      isClockVisible: store.preferences.isClockVisible
    ) {
      button.setAccessibilityLabel("TimeLedge \(title)")
    } else {
      button.setAccessibilityLabel("TimeLedge")
    }
  }

  func stop() {
    NSStatusBar.system.removeStatusItem(statusItem)
  }

  var isStatusItemVisible: Bool { statusItem.isVisible }
  var statusItemHasImage: Bool { statusItem.button?.image != nil }
  var statusItemLength: CGFloat { statusItem.length }

  func menuNeedsUpdate(_ menu: NSMenu) {
    refresh()
    showClockItem.state = store.preferences.isClockVisible ? .on : .off
    launchAtLoginItem.state = store.preferences.launchAtLogin ? .on : .off
  }

  @objc private func toggleClock() {
    store.preferences.isClockVisible.toggle()
  }

  @objc private func openSettings() {
    onOpenSettings()
  }

  @objc private func toggleLaunchAtLogin() {
    onSetLaunchAtLogin(!store.preferences.launchAtLogin)
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }
}
