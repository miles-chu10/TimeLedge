import AppKit
import TimeLedgeCore

/// Which displays should show the clock, and where the menu bar still is.
struct DisplayVisibilityState: Equatable {
  var visibleDisplayIDs: Set<String> = []
  var menuBarVisibleDisplayIDs: Set<String> = []
}

@MainActor
final class FullscreenVisibilityMonitor: NSObject {
  var onChange: ((DisplayVisibilityState) -> Void)?

  var appIsEnabled = true {
    didSet { evaluate(force: true) }
  }

  var mode: ClockVisibilityMode = .automatic {
    didSet { evaluate(force: true) }
  }

  private let displayProvider: DisplayProviding
  private let windowProbe = FrontmostWindowProbe()
  private let menuBarProbe = MenuBarWindowProbe()
  private var presenceTracker = MenuBarPresenceTracker()
  private var timer: Timer?
  private var sessionIsActive = true
  private var revealHoldUntil: [String: Date] = [:]
  private var lastState: DisplayVisibilityState?

  init(displayProvider: DisplayProviding) {
    self.displayProvider = displayProvider
  }

  func start() {
    let workspaceCenter = NSWorkspace.shared.notificationCenter
    workspaceCenter.addObserver(
      self,
      selector: #selector(environmentChanged),
      name: NSWorkspace.activeSpaceDidChangeNotification,
      object: nil
    )
    workspaceCenter.addObserver(
      self,
      selector: #selector(environmentChanged),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )
    workspaceCenter.addObserver(
      self,
      selector: #selector(sessionDidResign),
      name: NSWorkspace.sessionDidResignActiveNotification,
      object: nil
    )
    workspaceCenter.addObserver(
      self,
      selector: #selector(sessionDidBecomeActive),
      name: NSWorkspace.sessionDidBecomeActiveNotification,
      object: nil
    )
    workspaceCenter.addObserver(
      self,
      selector: #selector(sessionDidResign),
      name: NSWorkspace.screensDidSleepNotification,
      object: nil
    )
    workspaceCenter.addObserver(
      self,
      selector: #selector(sessionDidBecomeActive),
      name: NSWorkspace.screensDidWakeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(environmentChanged),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )

    let timer = Timer(
      timeInterval: 0.25,
      target: self,
      selector: #selector(poll),
      userInfo: nil,
      repeats: true
    )
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
    evaluate(force: true)
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    NotificationCenter.default.removeObserver(self)
  }

  func refresh() {
    evaluate(force: true)
  }

  @objc private func poll() {
    evaluate(force: false)
  }

  @objc private func environmentChanged() {
    evaluate(force: true)
  }

  @objc private func sessionDidResign() {
    sessionIsActive = false
    evaluate(force: true)
  }

  @objc private func sessionDidBecomeActive() {
    sessionIsActive = true
    evaluate(force: true)
  }

  /// Human-readable evidence for every display, used by `--diagnose`.
  func diagnosticsReport() -> String {
    let readings = currentReadings()
    guard !readings.isEmpty else {
      return "No displays reported."
    }
    return readings.map { reading in
      let menuBarWindow: String
      switch reading.evidence.menuBarWindowIsVisible {
      case .some(true): menuBarWindow = "visible"
      case .some(false): menuBarWindow = "hidden"
      case .none: menuBarWindow = "uncalibrated"
      }
      return """
        \(reading.name) [\(reading.id)]
          mode: \(mode.rawValue)
          menu-bar window: \(menuBarWindow)
          menu bar hidden by geometry: \(reading.evidence.menuBarIsHiddenByGeometry)
          frontmost window covers display: \(reading.evidence.frontmostWindowCoversDisplay)
          pointer revealing menu bar: \(reading.evidence.pointerIsRevealingMenuBar)
          session active: \(reading.evidence.sessionIsActive)
          clock enabled: \(reading.evidence.appIsEnabled)
          decision: \(reading.shouldShow ? "show" : "hide")
        """
    }
    .joined(separator: "\n")
  }

  private struct DisplayReading {
    let id: String
    let name: String
    let evidence: ClockVisibilityEvidence
    let shouldShow: Bool
  }

  private func currentReadings() -> [DisplayReading] {
    let displays = displayProvider.currentDisplays()
    let now = Date()
    let pointer = NSEvent.mouseLocation

    presenceTracker.retainCalibration(for: Set(displays.map(\.id)))
    let menuBarPresence = presenceTracker.update(
      menuBarWindows: menuBarProbe.samples(),
      displays: displays.map {
        MenuBarDisplaySample(id: $0.id, bounds: CGDisplayBounds($0.displayID))
      }
    )

    let frontmostWindowBounds: [CGRect]
    if let frontmostApplication = NSWorkspace.shared.frontmostApplication {
      frontmostWindowBounds = windowProbe.windowBounds(
        processIdentifier: frontmostApplication.processIdentifier
      )
    } else {
      frontmostWindowBounds = []
    }

    return displays.compactMap { display -> DisplayReading? in
      guard let screen = screen(for: display.displayID) else {
        return nil
      }

      let displayBounds = CGDisplayBounds(display.displayID)
      let isCovered = frontmostWindowBounds.contains { bounds in
        WindowCoverage.coversDisplay(
          windowBounds: bounds,
          displayBounds: displayBounds,
          allowedTopInset: display.fullscreenTopInset
        )
      }

      let revealBandHeight = max(NSStatusBar.system.thickness, screen.safeAreaInsets.top, 24)
      let pointerIsAtTop =
        screen.frame.contains(pointer)
        && pointer.y >= screen.frame.maxY - revealBandHeight
      if pointerIsAtTop {
        revealHoldUntil[display.id] = now.addingTimeInterval(0.9)
      }

      let evidence = ClockVisibilityEvidence(
        appIsEnabled: appIsEnabled,
        sessionIsActive: sessionIsActive,
        displayIsAvailable: true,
        menuBarIsHiddenByGeometry: abs(screen.frame.maxY - screen.visibleFrame.maxY) <= 1,
        menuBarWindowIsVisible: menuBarPresence[display.id],
        frontmostWindowCoversDisplay: isCovered,
        pointerIsRevealingMenuBar: now < revealHoldUntil[display.id, default: .distantPast]
      )

      return DisplayReading(
        id: display.id,
        name: display.localizedName,
        evidence: evidence,
        shouldShow: ClockVisibilityPolicy.shouldShowClock(mode: mode, evidence: evidence)
      )
    }
  }

  private func evaluate(force: Bool) {
    let readings = currentReadings()
    var state = DisplayVisibilityState()
    for reading in readings {
      if reading.shouldShow {
        state.visibleDisplayIDs.insert(reading.id)
      }
      // An uncalibrated probe means "unknown"; treat the menu bar as present so
      // the clock stays clear of the strip until the probe has seen it once.
      if reading.evidence.menuBarWindowIsVisible ?? !reading.evidence.menuBarIsHiddenByGeometry {
        state.menuBarVisibleDisplayIDs.insert(reading.id)
      }
    }

    guard force || lastState != state else {
      return
    }
    lastState = state
    onChange?(state)
  }

  private func screen(for displayID: CGDirectDisplayID) -> NSScreen? {
    NSScreen.screens.first { screen in
      guard
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
          as? NSNumber
      else {
        return false
      }
      return CGDirectDisplayID(number.uint32Value) == displayID
    }
  }
}
