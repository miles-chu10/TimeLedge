import CoreGraphics
import Foundation
import TimeLedgeCore

/// Reads the on-screen window metadata for the system menu bar.
///
/// This uses the same public `CGWindowListCopyWindowInfo` metadata the rest of
/// the app already relies on: window layer, bounds, and alpha. It never reads
/// window contents, so it needs no screen-recording permission.
struct MenuBarWindowProbe {
  private let menuBarLayer = Int(CGWindowLevelForKey(.mainMenuWindow))
  private let systemOwnerName = "Window Server"
  private let menuBarWindowName = "Menubar"

  /// Returns `nil` when the window list itself could not be read. That is not
  /// the same as an empty list: an empty list means no menu bar is on screen,
  /// while a failed read means the probe knows nothing and must not be allowed
  /// to claim every display's menu bar has gone away.
  func samples() -> [MenuBarWindowSample]? {
    guard
      let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else {
      return nil
    }

    return windowList.compactMap { window -> MenuBarWindowSample? in
      guard let layer = (window[kCGWindowLayer as String] as? NSNumber)?.intValue,
        layer == menuBarLayer,
        isSystemOwned(window),
        let dictionary = window[kCGWindowBounds as String] as? [String: NSNumber],
        let x = dictionary["X"]?.doubleValue,
        let y = dictionary["Y"]?.doubleValue,
        let width = dictionary["Width"]?.doubleValue,
        let height = dictionary["Height"]?.doubleValue
      else {
        return nil
      }

      return MenuBarWindowSample(
        bounds: CGRect(x: x, y: y, width: width, height: height),
        alpha: (window[kCGWindowAlpha as String] as? NSNumber)?.doubleValue ?? 1
      )
    }
  }

  /// The main-menu window level is public, so any process can put a window
  /// there. Only the window server's own menu bar counts, or a false positive
  /// would suppress the clock exactly when the menu bar is off screen.
  private func isSystemOwned(_ window: [String: Any]) -> Bool {
    if (window[kCGWindowOwnerName as String] as? String) == systemOwnerName {
      return true
    }
    // Window names are redacted without screen-recording permission, which
    // TimeLedge does not request, so this can only ever add a match.
    return (window[kCGWindowName as String] as? String) == menuBarWindowName
  }
}
