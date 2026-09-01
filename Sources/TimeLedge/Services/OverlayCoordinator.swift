import AppKit
import SwiftUI
import TimeLedgeCore

@MainActor
final class OverlayCoordinator {
  private struct Record {
    let panel: OverlayPanel
    let hostingView: NSHostingView<ClockView>
  }

  private let store: PreferencesStore
  private let displayProvider: DisplayProviding
  private var records: [String: Record] = [:]
  private var observers: [NSObjectProtocol] = []
  private var visibilityState = DisplayVisibilityState()

  init(store: PreferencesStore, displayProvider: DisplayProviding) {
    self.store = store
    self.displayProvider = displayProvider
  }

  func start() {
    let center = NotificationCenter.default
    observers.append(
      center.addObserver(
        forName: NSApplication.didChangeScreenParametersNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        Task { @MainActor in
          self?.refreshDisplays()
        }
      }
    )

    let workspaceCenter = NSWorkspace.shared.notificationCenter
    observers.append(
      workspaceCenter.addObserver(
        forName: NSWorkspace.activeSpaceDidChangeNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        Task { @MainActor in
          self?.applyPreferences()
        }
      }
    )
    observers.append(
      workspaceCenter.addObserver(
        forName: NSWorkspace.didWakeNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        Task { @MainActor in
          self?.refreshDisplays()
        }
      }
    )

    refreshDisplays()
  }

  func stop() {
    for observer in observers {
      NotificationCenter.default.removeObserver(observer)
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
    observers.removeAll()
    for record in records.values {
      record.panel.orderOut(nil)
    }
    records.removeAll()
  }

  func refreshDisplays() {
    store.synchronize(displays: displayProvider.currentDisplays())
    applyPreferences()
  }

  func applyPreferences() {
    let connectedIDs = Set(store.displays.map { $0.id })
    let staleIDs = records.keys.filter { !connectedIDs.contains($0) }
    for id in staleIDs {
      if let staleRecord = records.removeValue(forKey: id) {
        staleRecord.panel.orderOut(nil)
      }
    }

    guard store.preferences.isClockVisible else {
      for record in records.values {
        record.panel.orderOut(nil)
      }
      return
    }

    for display in store.displays {
      let displayPreference = store.preference(for: display.id)
      let modeAllowsDisplay = visibilityState.visibleDisplayIDs.contains(display.id)
      guard displayPreference.isEnabled, modeAllowsDisplay else {
        records[display.id]?.panel.orderOut(nil)
        continue
      }

      let record = recordForDisplay(display)
      record.hostingView.rootView = clockView(for: display)
      record.hostingView.layoutSubtreeIfNeeded()

      let measuredSize = record.hostingView.fittingSize
      let contentSize = CGSize(
        width: max(1, measuredSize.width),
        height: max(1, measuredSize.height)
      )
      record.panel.level = store.preferences.windowLayer.windowLevel
      updateFrame(for: display.id, contentSize: contentSize)
      if store.preferences.windowLayer == .overApps {
        record.panel.orderFrontRegardless()
      } else {
        record.panel.orderBack(nil)
      }
    }
  }

  func setVisibilityState(_ state: DisplayVisibilityState) {
    guard visibilityState != state else {
      return
    }
    visibilityState = state
    applyPreferences()
  }

  private func menuBarIsVisible(on displayID: String) -> Bool {
    visibilityState.menuBarVisibleDisplayIDs.contains(displayID)
  }

  func writeSnapshots(to directory: URL) throws {
    for (displayID, record) in records {
      guard let contentView = record.panel.contentView,
        record.panel.isVisible
      else {
        continue
      }
      let safeID = displayID.replacingOccurrences(of: "/", with: "-")
      try ViewSnapshotWriter.write(
        view: contentView,
        to: directory.appendingPathComponent("overlay-\(safeID).png")
      )
    }
  }

  private func recordForDisplay(_ display: DisplayDescriptor) -> Record {
    if let existing = records[display.id] {
      return existing
    }

    let hostingView = NSHostingView(rootView: clockView(for: display))
    hostingView.wantsLayer = true
    hostingView.layer?.backgroundColor = NSColor.clear.cgColor

    let panel = OverlayPanel()
    panel.contentView = hostingView
    let record = Record(panel: panel, hostingView: hostingView)
    records[display.id] = record
    return record
  }

  private func clockView(for display: DisplayDescriptor) -> ClockView {
    let horizontalPadding: CGFloat = store.preference(for: display.id).showsBackground ? 16 : 0
    let maximumWidth = OverlayPlacement.maximumContentWidth(
      in: display.placementBounds(menuBarIsVisible: menuBarIsVisible(on: display.id)),
      rightMargin: CGFloat(store.preferences.rightMargin.points),
      horizontalPadding: horizontalPadding
    )
    return ClockView(
      store: store,
      displayID: display.id,
      maximumWidth: maximumWidth,
      onSizeChange: { [weak self] size in
        self?.updateFrame(for: display.id, contentSize: size)
      }
    )
  }

  private func updateFrame(for displayID: String, contentSize: CGSize) {
    guard store.preferences.isClockVisible,
      let display = store.displays.first(where: { $0.id == displayID }),
      let record = records[displayID],
      store.preference(for: displayID).isEnabled,
      visibilityState.visibleDisplayIDs.contains(displayID)
    else {
      return
    }

    let menuBarIsOnScreen = menuBarIsVisible(on: displayID)
    let frame = OverlayPlacement.frame(
      in: display.placementBounds(menuBarIsVisible: menuBarIsOnScreen),
      contentSize: contentSize,
      rightMargin: CGFloat(store.preferences.rightMargin.points),
      alignment: menuBarIsOnScreen ? .top : .centered
    )
    guard record.panel.frame != frame else {
      return
    }
    record.panel.setOverlayFrame(frame, display: true)
  }
}
