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

  func samples() -> [MenuBarWindowSample] {
    guard
      let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else {
      return []
    }

    return windowList.compactMap { window -> MenuBarWindowSample? in
      guard let layer = (window[kCGWindowLayer as String] as? NSNumber)?.intValue,
        layer == menuBarLayer,
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
}
