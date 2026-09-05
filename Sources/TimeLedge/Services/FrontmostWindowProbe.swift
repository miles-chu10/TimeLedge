import CoreGraphics
import Foundation

/// Reads the on-screen bounds of the frontmost application's ordinary windows.
struct FrontmostWindowProbe {
  func windowBounds(processIdentifier: pid_t) -> [CGRect] {
    guard processIdentifier > 0,
      let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else {
      return []
    }

    return windowList.compactMap { window -> CGRect? in
      guard
        (window[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value
          == processIdentifier,
        (window[kCGWindowLayer as String] as? NSNumber)?.intValue == 0
      else {
        return nil
      }

      let alpha = (window[kCGWindowAlpha as String] as? NSNumber)?.doubleValue ?? 1
      guard alpha > 0.01,
        let dictionary = window[kCGWindowBounds as String] as? [String: NSNumber],
        let x = dictionary["X"]?.doubleValue,
        let y = dictionary["Y"]?.doubleValue,
        let width = dictionary["Width"]?.doubleValue,
        let height = dictionary["Height"]?.doubleValue
      else {
        return nil
      }
      return CGRect(x: x, y: y, width: width, height: height)
    }
  }
}
