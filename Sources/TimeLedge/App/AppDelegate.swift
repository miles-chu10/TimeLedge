import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var store: PreferencesStore!
  private var overlayCoordinator: OverlayCoordinator!
  private var visibilityMonitor: FullscreenVisibilityMonitor!
  private var settingsWindowController: SettingsWindowController!
  private var statusItemController: StatusItemController!

  func applicationDidFinishLaunching(_ notification: Notification) {
    let arguments = CommandLine.arguments
    NSApp.setActivationPolicy(.accessory)

    store = PreferencesStore()
    store.setLaunchAtLoginState(LoginItemController.isEnabledOrAwaitingApproval)

    let displayProvider = SystemDisplayProvider()
    overlayCoordinator = OverlayCoordinator(
      store: store,
      displayProvider: displayProvider
    )
    visibilityMonitor = FullscreenVisibilityMonitor(displayProvider: displayProvider)

    settingsWindowController = SettingsWindowController(
      store: store,
      onSetLaunchAtLogin: { [weak self] enabled in
        self?.setLaunchAtLogin(enabled)
      },
      onRefreshDisplays: { [weak self] in
        self?.overlayCoordinator.refreshDisplays()
      },
      initialSection: settingsSection(from: arguments)
    )

    statusItemController = StatusItemController(
      store: store,
      onOpenSettings: { [weak self] in
        self?.settingsWindowController.show()
      },
      onSetLaunchAtLogin: { [weak self] enabled in
        self?.setLaunchAtLogin(enabled)
      }
    )

    visibilityMonitor.menuBarItemVisibility = { [weak self] displayID in
      self?.statusItemController?.isVisibleInMenuBar(on: displayID)
    }

    store.changeHandler = { [weak self] in
      self?.visibilityMonitor.appIsEnabled = self?.store.preferences.isClockVisible ?? false
      self?.visibilityMonitor.mode = self?.store.visibilityMode ?? .automatic
      self?.overlayCoordinator.applyPreferences()
    }

    visibilityMonitor.onChange = { [weak self] displayIDs in
      self?.overlayCoordinator.setAutomaticallyVisibleDisplayIDs(displayIDs)
    }

    overlayCoordinator.start()
    visibilityMonitor.appIsEnabled = store.preferences.isClockVisible
    visibilityMonitor.mode = store.visibilityMode
    visibilityMonitor.start()

    if arguments.contains("--show-settings") {
      DispatchQueue.main.async { [weak self] in
        self?.settingsWindowController.show()
      }
    }

    #if DEBUG
      if let flagIndex = arguments.firstIndex(of: "--snapshot-dir"),
        arguments.indices.contains(flagIndex + 1)
      {
        let directory = URL(fileURLWithPath: arguments[flagIndex + 1], isDirectory: true)
        settingsWindowController.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
          self?.writeDebugSnapshots(to: directory)
        }
      }
    #endif
  }

  func applicationWillTerminate(_ notification: Notification) {
    visibilityMonitor?.stop()
    overlayCoordinator?.stop()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    false
  }

  private func setLaunchAtLogin(_ enabled: Bool) {
    do {
      try LoginItemController.setEnabled(enabled)
      store.loginItemError =
        LoginItemController.requiresApproval
        ? "Approve TimeLedge in System Settings → General → Login Items."
        : nil
      store.setLaunchAtLoginState(enabled)
    } catch {
      store.loginItemError = "Launch at login could not be changed: \(error.localizedDescription)"
      store.setLaunchAtLoginState(LoginItemController.isEnabledOrAwaitingApproval)
    }
  }

  private func settingsSection(from arguments: [String]) -> SettingsSection {
    guard let index = arguments.firstIndex(of: "--settings-section"),
      arguments.indices.contains(index + 1)
    else {
      return .format
    }
    let requested = arguments[index + 1].lowercased()
    return SettingsSection.allCases.first(where: { $0.rawValue.lowercased() == requested })
      ?? .format
  }

  #if DEBUG
    private func writeDebugSnapshots(to directory: URL) {
      do {
        try FileManager.default.createDirectory(
          at: directory,
          withIntermediateDirectories: true,
          attributes: nil
        )
        try settingsWindowController.writeSnapshot(
          to: directory.appendingPathComponent("settings.png")
        )
        try overlayCoordinator.writeSnapshots(to: directory)
      } catch {
        NSLog("TimeLedge debug snapshot failed: %@", error.localizedDescription)
      }
    }
  #endif
}
