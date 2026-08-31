import AppKit
import CoreGraphics
import TimeLedgeCore

@MainActor
protocol DisplayProviding {
  func currentDisplays() -> [DisplayDescriptor]
}

@MainActor
final class SystemDisplayProvider: DisplayProviding {
  /// Largest menu-bar band height seen per display while the menu bar was
  /// visible. A fullscreen Space hides the menu bar, which collapses
  /// `visibleFrame` back to `frame`; without this cache the band would shrink to
  /// the status-bar fallback exactly when the overlay needs it most.
  private var cachedMenuBarHeights: [CGDirectDisplayID: CGFloat] = [:]

  func currentDisplays() -> [DisplayDescriptor] {
    NSScreen.screens.compactMap { screen in
      guard
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
      else {
        return nil
      }

      let displayID = CGDirectDisplayID(number.uint32Value)
      let observedMenuBarHeight = Self.observedMenuBarHeight(
        screenFrame: screen.frame,
        visibleFrame: screen.visibleFrame
      )
      let menuBarHeight = rememberMenuBarHeight(observedMenuBarHeight, for: displayID)

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
          menuBarHeight: menuBarHeight,
          auxiliaryTopRightArea: screen.auxiliaryTopRightArea
        ),
        fullscreenTopInset: Self.fullscreenTopInset(
          safeAreaTop: screen.safeAreaInsets.top,
          statusBarThickness: NSStatusBar.system.thickness
        )
      )
    }
  }

  /// Menu-bar band height inferred from the gap the menu bar leaves at the top
  /// of `visibleFrame`. Returns 0 when the menu bar is hidden or auto-hidden.
  static func observedMenuBarHeight(
    screenFrame: CGRect,
    visibleFrame: CGRect
  ) -> CGFloat {
    let gap = screenFrame.maxY - visibleFrame.maxY
    return gap > 1 ? gap : 0
  }

  static func fullscreenTopInset(
    safeAreaTop: CGFloat,
    statusBarThickness: CGFloat
  ) -> CGFloat {
    safeAreaTop > statusBarThickness + 1 ? safeAreaTop : 0
  }

  /// The menu-bar band the clock draws inside, in AppKit screen coordinates.
  ///
  /// On a notched display the hardware-reported top-right auxiliary area already
  /// describes the band beside the notch. Everywhere else the band height comes
  /// from the observed menu-bar height, falling back to the status-bar thickness
  /// only when nothing better has been seen.
  static func topRightPlacementBounds(
    screenFrame: CGRect,
    safeAreaTop: CGFloat,
    statusBarThickness: CGFloat,
    menuBarHeight: CGFloat = 0,
    auxiliaryTopRightArea: CGRect?
  ) -> CGRect {
    if let area = auxiliaryTopRightArea, !area.isEmpty {
      let height = min(max(1, area.height, menuBarHeight), screenFrame.height)
      let width = min(max(1, area.width), screenFrame.width)
      return CGRect(
        x: screenFrame.maxX - width,
        y: screenFrame.maxY - height,
        width: width,
        height: height
      )
    }

    let bandHeight = max(1, safeAreaTop, menuBarHeight, statusBarThickness)
    let hasLikelyNotch =
      fullscreenTopInset(
        safeAreaTop: safeAreaTop,
        statusBarThickness: statusBarThickness
      ) > 0
    return OverlayPlacement.menuBarBand(
      screenFrame: screenFrame,
      bandHeight: bandHeight,
      minimumX: hasLikelyNotch ? screenFrame.midX : screenFrame.minX
    )
  }

  private func rememberMenuBarHeight(
    _ observed: CGFloat,
    for displayID: CGDirectDisplayID
  ) -> CGFloat {
    guard observed > 1 else {
      return cachedMenuBarHeights[displayID] ?? 0
    }
    cachedMenuBarHeights[displayID] = observed
    return observed
  }

  private func stableIdentifier(for displayID: CGDirectDisplayID) -> String {
    if let unmanagedUUID = CGDisplayCreateUUIDFromDisplayID(displayID) {
      let uuid = unmanagedUUID.takeRetainedValue()
      return CFUUIDCreateString(nil, uuid) as String
    }
    return "display-\(displayID)"
  }
}
