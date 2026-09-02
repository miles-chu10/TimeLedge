import CoreGraphics
import Foundation

/// One on-screen window that the window server draws in the menu-bar layer.
///
/// Bounds use Core Graphics display coordinates, whose origin is the top-left
/// corner of the global display space.
public struct MenuBarWindowSample: Equatable, Sendable {
  public let bounds: CGRect
  public let alpha: Double

  public init(bounds: CGRect, alpha: Double = 1) {
    self.bounds = bounds
    self.alpha = alpha
  }
}

/// A display expressed in the same Core Graphics coordinates as the samples.
public struct MenuBarDisplaySample: Equatable, Sendable {
  public let id: String
  public let bounds: CGRect

  public init(id: String, bounds: CGRect) {
    self.id = id
    self.bounds = bounds
  }
}

/// Tracks whether the real system menu bar is currently drawn on each display.
///
/// This is the direct observation TimeLedge actually cares about: the clock
/// exists to replace the menu-bar clock while the menu bar is not on screen.
/// Inferring that state from Spaces transitions produced false negatives -- a
/// fullscreen window that was already fullscreen when TimeLedge launched, or
/// one whose Space was left and re-entered, was never recognized.
///
/// The tracker self-calibrates per display: a display only reports `false`
/// (menu bar hidden) once the menu bar has actually been observed on it, so an
/// unexpected window-server layout reports "unknown" -- an absent dictionary
/// entry -- instead of a confident wrong answer. Callers fall back to geometry
/// and window-coverage evidence when the answer is unknown.
public struct MenuBarPresenceTracker: Sendable {
  public private(set) var calibratedDisplayIDs: Set<String> = []
  private var lastPresence: [String: Bool] = [:]

  public init() {}

  /// Returns `displayID -> menu bar is on screen`, omitting displays whose menu
  /// bar has never been observed.
  ///
  /// `menuBarWindows` is `nil` when the window list could not be read at all.
  /// That is deliberately not treated as "no menu bar anywhere": the last known
  /// answer is repeated instead, because reporting every calibrated display as
  /// hidden would show the clock on top of a menu bar that is still drawn.
  public mutating func update(
    menuBarWindows: [MenuBarWindowSample]?,
    displays: [MenuBarDisplaySample]
  ) -> [String: Bool] {
    guard let menuBarWindows else {
      return lastPresence.filter { entry in
        displays.contains { $0.id == entry.key }
      }
    }

    var presence: [String: Bool] = [:]
    for display in displays {
      let isVisible = menuBarWindows.contains { window in
        Self.sample(window, coversTopOf: display.bounds)
      }
      if isVisible {
        calibratedDisplayIDs.insert(display.id)
      }
      guard calibratedDisplayIDs.contains(display.id) else { continue }
      presence[display.id] = isVisible
    }
    lastPresence = presence
    return presence
  }

  /// Forgets calibration for displays that are no longer connected.
  public mutating func retainCalibration(for displayIDs: Set<String>) {
    calibratedDisplayIDs.formIntersection(displayIDs)
    lastPresence = lastPresence.filter { displayIDs.contains($0.key) }
  }

  public static func sample(
    _ window: MenuBarWindowSample,
    coversTopOf displayBounds: CGRect,
    maximumThickness: CGFloat = 64,
    minimumWidthRatio: CGFloat = 0.5,
    edgeTolerance: CGFloat = 2
  ) -> Bool {
    guard window.alpha > 0.01,
      displayBounds.width > 0,
      displayBounds.height > 0,
      window.bounds.height > 0,
      window.bounds.height <= maximumThickness,
      abs(window.bounds.minY - displayBounds.minY) <= edgeTolerance
    else {
      return false
    }

    let overlap = window.bounds.intersection(displayBounds)
    guard !overlap.isNull, !overlap.isEmpty else {
      return false
    }
    return overlap.width >= displayBounds.width * minimumWidthRatio
  }
}
