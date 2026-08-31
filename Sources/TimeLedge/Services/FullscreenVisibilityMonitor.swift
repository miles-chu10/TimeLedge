import AppKit
import TimeLedgeCore

@MainActor
final class FullscreenVisibilityMonitor: NSObject {
  var onChange: ((Set<String>) -> Void)?
  var menuBarItemVisibility: ((CGDirectDisplayID) -> Bool?)?

  var appIsEnabled = true {
    didSet { evaluate(force: true) }
  }

  var mode: ClockVisibilityMode = .automatic {
    didSet { evaluate(force: true) }
  }

  private let displayProvider: DisplayProviding
  private let probe = FrontmostWindowProbe()
  private var timer: Timer?
  private var sessionIsActive = true
  private var revealHoldUntil: [String: Date] = [:]
  private var lastVisibleDisplayIDs: Set<String>?

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

  private func evaluate(force: Bool) {
    let displays = displayProvider.currentDisplays()
    let now = Date()
    let pointer = NSEvent.mouseLocation
    let coveredDisplayIDs: Set<String>

    if let frontmostApplication = NSWorkspace.shared.frontmostApplication {
      coveredDisplayIDs = probe.coveredDisplayIDs(
        processIdentifier: frontmostApplication.processIdentifier,
        displays: displays
      )
    } else {
      coveredDisplayIDs = []
    }

    let visibleDisplayIDs = Set(
      displays.compactMap { display -> String? in
        guard let screen = screen(for: display.displayID) else {
          return nil
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
          menuBarIsHiddenByGeometry:
            abs(screen.frame.maxY - screen.visibleFrame.maxY) <= 1
            || menuBarItemVisibility?(display.displayID) == false,
          frontmostWindowCoversDisplay: coveredDisplayIDs.contains(display.id),
          pointerIsRevealingMenuBar: now < revealHoldUntil[display.id, default: .distantPast]
        )

        return ClockVisibilityPolicy.shouldShowClock(mode: mode, evidence: evidence)
          ? display.id : nil
      })

    guard force || lastVisibleDisplayIDs != visibleDisplayIDs else {
      return
    }
    lastVisibleDisplayIDs = visibleDisplayIDs
    onChange?(visibleDisplayIDs)
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
