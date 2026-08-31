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
        topRightSafeArea: Self.topRightPlacementBounds(
          screenFrame: screen.frame,
          safeAreaTop: screen.safeAreaInsets.top,
          statusBarThickness: NSStatusBar.system.thickness,
          auxiliaryTopRightArea: screen.auxiliaryTopRightArea
        ),
        fullscreenTopInset: Self.fullscreenTopInset(
          safeAreaTop: screen.safeAreaInsets.top,
          statusBarThickness: NSStatusBar.system.thickness
        )
      )
    }
  }

  static func fullscreenTopInset(
    safeAreaTop: CGFloat,
    statusBarThickness: CGFloat
  ) -> CGFloat {
    safeAreaTop > statusBarThickness + 1 ? safeAreaTop : 0
  }

  static func topRightPlacementBounds(
    screenFrame: CGRect,
    safeAreaTop: CGFloat,
    statusBarThickness: CGFloat,
    auxiliaryTopRightArea: CGRect?
  ) -> CGRect {
    if let area = auxiliaryTopRightArea, !area.isEmpty {
      let height = min(max(1, area.height), screenFrame.height)
      let width = min(max(1, area.width), screenFrame.width)
      return CGRect(
        x: screenFrame.maxX - width,
        y: screenFrame.maxY - height,
        width: width,
        height: height
      )
    }

    let height = min(
      max(1, safeAreaTop, statusBarThickness),
      screenFrame.height
    )
    let hasLikelyNotch =
      fullscreenTopInset(
        safeAreaTop: safeAreaTop,
        statusBarThickness: statusBarThickness
      ) > 0
    let minX = hasLikelyNotch ? screenFrame.midX : screenFrame.minX
    return CGRect(
      x: minX,
      y: screenFrame.maxY - height,
      width: screenFrame.maxX - minX,
      height: height
    )
  }

  private func stableIdentifier(for displayID: CGDirectDisplayID) -> String {
    if let unmanagedUUID = CGDisplayCreateUUIDFromDisplayID(displayID) {
      let uuid = unmanagedUUID.takeRetainedValue()
      return CFUUIDCreateString(nil, uuid) as String
    }
    return "display-\(displayID)"
  }
}
