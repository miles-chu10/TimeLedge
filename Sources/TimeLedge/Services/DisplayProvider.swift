import AppKit
import CoreGraphics

@MainActor
protocol DisplayProviding {
  func currentDisplays() -> [DisplayDescriptor]
}

@MainActor
struct SystemDisplayProvider: DisplayProviding {
  func currentDisplays() -> [DisplayDescriptor] {
    NSScreen.screens.compactMap { screen in
      guard
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
      else {
        return nil
      }

      let displayID = CGDirectDisplayID(number.uint32Value)
      return DisplayDescriptor(
        id: stableIdentifier(for: displayID),
        localizedName: screen.localizedName,
        displayID: displayID,
        isBuiltIn: CGDisplayIsBuiltin(displayID) != 0,
        frame: screen.frame,
        topRightSafeArea: screen.auxiliaryTopRightArea
      )
    }
  }

  private func stableIdentifier(for displayID: CGDirectDisplayID) -> String {
    if let unmanagedUUID = CGDisplayCreateUUIDFromDisplayID(displayID) {
      let uuid = unmanagedUUID.takeRetainedValue()
      return CFUUIDCreateString(nil, uuid) as String
    }
    return "display-\(displayID)"
  }
}
