import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
  init(
    store: PreferencesStore,
    onSetLaunchAtLogin: @escaping (Bool) -> Void,
    onRefreshDisplays: @escaping () -> Void,
    initialSection: SettingsSection = .format
  ) {
    let rootView = SettingsView(
      store: store,
      onSetLaunchAtLogin: onSetLaunchAtLogin,
      onRefreshDisplays: onRefreshDisplays,
      initialSection: initialSection
    )
    let hostingController = NSHostingController(rootView: rootView)
    let window = NSWindow(
      contentRect: CGRect(x: 0, y: 0, width: 520, height: 680),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    window.title = "TimeLedge Settings"
    window.contentViewController = hostingController
    window.isReleasedWhenClosed = false
    window.minSize = CGSize(width: 520, height: 560)
    window.center()
    super.init(window: window)
  }

  required init?(coder: NSCoder) {
    nil
  }

  func show() {
    NSApp.activate(ignoringOtherApps: true)
    window?.makeKeyAndOrderFront(nil)
  }

  func writeSnapshot(to url: URL) throws {
    guard let contentView = window?.contentView else {
      throw ViewSnapshotWriter.SnapshotError.emptyView
    }
    try ViewSnapshotWriter.write(view: contentView, to: url)
  }
}
