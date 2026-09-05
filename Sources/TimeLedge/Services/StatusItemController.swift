import AppKit
import TimeLedgeCore

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
  private let store: PreferencesStore
  private let statusItem: NSStatusItem
  private let onOpenSettings: () -> Void
  private let onSetLaunchAtLogin: (Bool) -> Void
  private var clockTimer: Timer?
  private var renderedTitle: String?
  private var hasRendered = false

  private lazy var showClockItem = NSMenuItem(
    title: "Show Clock",
    action: #selector(toggleClock),
    keyEquivalent: ""
  )
  private lazy var showMenuBarClockItem = NSMenuItem(
    title: "Show Time in Menu Bar",
    action: #selector(toggleMenuBarClock),
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

    let clockTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
      Task { @MainActor [weak self] in
        self?.refresh()
      }
    }
    RunLoop.main.add(clockTimer, forMode: .common)
    self.clockTimer = clockTimer

    let menu = NSMenu()
    menu.delegate = self
    showClockItem.target = self
    showMenuBarClockItem.target = self
    launchAtLoginItem.target = self
    menu.addItem(showClockItem)
    menu.addItem(showMenuBarClockItem)
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

  /// The text to draw in the real menu bar, or `nil` for the icon-only item.
  ///
  /// macOS already draws a menu-bar clock, so TimeLedge stays an icon unless
  /// the user explicitly opts in to a second one.
  static func menuBarTitle(
    at date: Date,
    preferences: ClockPreferences,
    isClockVisible: Bool
  ) -> String? {
    guard isClockVisible, preferences.showsMenuBarClock else { return nil }
    return ClockFormatter.string(from: date, preferences: preferences)
  }

  func refresh() {
    guard let button = statusItem.button else { return }
    let title = Self.menuBarTitle(
      at: Date(),
      preferences: store.preferences,
      isClockVisible: store.preferences.isClockVisible
    )
    guard title != renderedTitle || !hasRendered else {
      return
    }
    hasRendered = true
    renderedTitle = title

    if let title {
      statusItem.length = NSStatusItem.variableLength
      button.image = nil
      button.imagePosition = .noImage
      button.title = title
      button.setAccessibilityLabel("TimeLedge \(title)")
    } else {
      statusItem.length = NSStatusItem.squareLength
      button.title = ""
      button.image = NSImage(
        systemSymbolName: "clock",
        accessibilityDescription: "TimeLedge"
      )
      button.imagePosition = .imageOnly
      button.setAccessibilityLabel("TimeLedge")
    }
  }

  func stop() {
    clockTimer?.invalidate()
    clockTimer = nil
    NSStatusBar.system.removeStatusItem(statusItem)
  }

  var isStatusItemVisible: Bool { statusItem.isVisible }

  func menuNeedsUpdate(_ menu: NSMenu) {
    refresh()
    showClockItem.state = store.preferences.isClockVisible ? .on : .off
    showMenuBarClockItem.state = store.preferences.showsMenuBarClock ? .on : .off
    launchAtLoginItem.state = store.preferences.launchAtLogin ? .on : .off
  }

  @objc private func toggleClock() {
    store.preferences.isClockVisible.toggle()
  }

  @objc private func toggleMenuBarClock() {
    store.preferences.showsMenuBarClock.toggle()
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
