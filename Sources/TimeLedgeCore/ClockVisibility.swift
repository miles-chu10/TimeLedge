import Foundation

public enum ClockVisibilityMode: String, CaseIterable, Codable, Identifiable {
  case automatic
  case fullscreenOnly
  case always

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .automatic: return "Hidden or Fullscreen"
    case .fullscreenOnly: return "Fullscreen Only"
    case .always: return "Always"
    }
  }

  public var detail: String {
    switch self {
    case .automatic:
      return "Shows whenever the system menu bar is not on screen, including fullscreen Spaces."
    case .fullscreenOnly:
      return "Shows only while the frontmost window covers the whole display."
    case .always:
      return "Shows on every enabled display until you turn the clock off."
    }
  }
}

public struct ClockVisibilityEvidence: Equatable, Sendable {
  public var appIsEnabled: Bool
  public var sessionIsActive: Bool
  public var displayIsAvailable: Bool
  public var menuBarIsHiddenByGeometry: Bool
  /// Whether the window server currently draws the menu bar on this display.
  /// `nil` means the menu-bar probe has not been calibrated for the display
  /// yet, so the geometry and coverage evidence decide on their own.
  public var menuBarWindowIsVisible: Bool?
  public var frontmostWindowCoversDisplay: Bool
  public var pointerIsRevealingMenuBar: Bool

  public init(
    appIsEnabled: Bool,
    sessionIsActive: Bool,
    displayIsAvailable: Bool,
    menuBarIsHiddenByGeometry: Bool,
    menuBarWindowIsVisible: Bool? = nil,
    frontmostWindowCoversDisplay: Bool,
    pointerIsRevealingMenuBar: Bool
  ) {
    self.appIsEnabled = appIsEnabled
    self.sessionIsActive = sessionIsActive
    self.displayIsAvailable = displayIsAvailable
    self.menuBarIsHiddenByGeometry = menuBarIsHiddenByGeometry
    self.menuBarWindowIsVisible = menuBarWindowIsVisible
    self.frontmostWindowCoversDisplay = frontmostWindowCoversDisplay
    self.pointerIsRevealingMenuBar = pointerIsRevealingMenuBar
  }
}

public enum ClockVisibilityPolicy {
  public static func shouldShowClock(
    mode: ClockVisibilityMode,
    evidence: ClockVisibilityEvidence
  ) -> Bool {
    guard evidence.appIsEnabled,
      evidence.sessionIsActive,
      evidence.displayIsAvailable
    else {
      return false
    }

    if mode == .always {
      return true
    }

    guard !evidence.pointerIsRevealingMenuBar else {
      return false
    }

    // A positive probe observation is authoritative: the system menu bar is
    // drawn on this display, so the system clock is already there and must not
    // be duplicated. Geometry cannot overrule it -- with the system set to
    // auto-hide the menu bar, `visibleFrame` reports full height even while the
    // menu bar is revealed, so geometry cannot see the difference at all.
    if evidence.menuBarWindowIsVisible == true {
      return false
    }

    switch mode {
    case .automatic:
      return evidence.menuBarWindowIsVisible == false
        || evidence.menuBarIsHiddenByGeometry
        || evidence.frontmostWindowCoversDisplay
    case .fullscreenOnly:
      return evidence.frontmostWindowCoversDisplay
    case .always:
      return true
    }
  }
}
