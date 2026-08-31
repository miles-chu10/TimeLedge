import CoreGraphics
import Foundation
import TimeLedgeCore

struct FrontmostWindowProbe {
  func coveredDisplayIDs(
    processIdentifier: pid_t,
    displays: [DisplayDescriptor]
  ) -> Set<String> {
    guard processIdentifier > 0,
      let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else {
      return []
    }

    let candidateBounds = windowList.compactMap { window -> CGRect? in
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

    return Set(
      displays.compactMap { display in
        candidateBounds.contains(where: {
          WindowCoverage.coversDisplay(
            windowBounds: $0,
            displayBounds: CGDisplayBounds(display.displayID),
            allowedTopInset: display.topRightSafeArea?.height ?? 0
          )
        }) ? display.id : nil
      })
  }
}
