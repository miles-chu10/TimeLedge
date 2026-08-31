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
      return "Shows when the menu bar is hidden or the frontmost app fills the display."
    case .fullscreenOnly:
      return "Shows only when the menu bar is hidden and the frontmost app covers the display."
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
  public var frontmostWindowCoversDisplay: Bool
  public var pointerIsRevealingMenuBar: Bool

  public init(
    appIsEnabled: Bool,
    sessionIsActive: Bool,
    displayIsAvailable: Bool,
    menuBarIsHiddenByGeometry: Bool,
    frontmostWindowCoversDisplay: Bool,
    pointerIsRevealingMenuBar: Bool
  ) {
    self.appIsEnabled = appIsEnabled
    self.sessionIsActive = sessionIsActive
    self.displayIsAvailable = displayIsAvailable
    self.menuBarIsHiddenByGeometry = menuBarIsHiddenByGeometry
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

    switch mode {
    case .automatic:
      return evidence.menuBarIsHiddenByGeometry
        || evidence.frontmostWindowCoversDisplay
    case .fullscreenOnly:
      return evidence.frontmostWindowCoversDisplay
    case .always:
      return true
    }
  }
}
