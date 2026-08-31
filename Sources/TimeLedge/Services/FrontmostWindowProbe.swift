import CoreGraphics
import Foundation
import TimeLedgeCore

struct FrontmostWindowObservation {
  let identity: WindowIdentity
  let bounds: CGRect
}

struct FrontmostWindowProbe {
  func observations(processIdentifier: pid_t) -> [FrontmostWindowObservation] {
    guard processIdentifier > 0,
      let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else {
      return []
    }

    return windowList.compactMap { window -> FrontmostWindowObservation? in
      guard
        (window[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value
          == processIdentifier,
        (window[kCGWindowLayer as String] as? NSNumber)?.intValue == 0,
        let windowNumber = (window[kCGWindowNumber as String] as? NSNumber)?.uint32Value
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
      return FrontmostWindowObservation(
        identity: WindowIdentity(
          ownerProcessIdentifier: processIdentifier,
          windowNumber: windowNumber
        ),
        bounds: CGRect(x: x, y: y, width: width, height: height)
      )
    }
  }
}
