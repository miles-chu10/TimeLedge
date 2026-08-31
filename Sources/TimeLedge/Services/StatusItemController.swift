import AppKit
import CoreGraphics

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
  private let store: PreferencesStore
  private let statusItem: NSStatusItem
  private let onOpenSettings: () -> Void
  private let onSetLaunchAtLogin: (Bool) -> Void
  private var lastMenuBarDisplayID: CGDirectDisplayID?

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

  func isVisibleInMenuBar(on displayID: CGDirectDisplayID) -> Bool? {
    guard let window = statusItem.button?.window else {
      return nil
    }

    if let currentDisplayID = window.screen.flatMap(Self.displayID(for:)) {
      lastMenuBarDisplayID = currentDisplayID
    } else if lastMenuBarDisplayID == nil {
      lastMenuBarDisplayID = NSScreen.main.flatMap(Self.displayID(for:))
    }

    guard lastMenuBarDisplayID == displayID else { return nil }
    return window.isVisible && window.occlusionState.contains(.visible)
  }

  private static func displayID(for screen: NSScreen) -> CGDirectDisplayID? {
    guard
      let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
        as? NSNumber
    else {
      return nil
    }
    return CGDirectDisplayID(number.uint32Value)
  }

  init(
    store: PreferencesStore,
    onOpenSettings: @escaping () -> Void,
    onSetLaunchAtLogin: @escaping (Bool) -> Void
  ) {
    self.store = store
    self.onOpenSettings = onOpenSettings
    self.onSetLaunchAtLogin = onSetLaunchAtLogin
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    super.init()

    statusItem.button?.image = NSImage(
      systemSymbolName: "clock",
      accessibilityDescription: "TimeLedge"
    )

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

  func menuNeedsUpdate(_ menu: NSMenu) {
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
