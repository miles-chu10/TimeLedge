import AppKit
import CoreGraphics

struct DisplayDescriptor: Identifiable, Equatable {
  let id: String
  let localizedName: String
  let displayID: CGDirectDisplayID
  let isBuiltIn: Bool
  let frame: CGRect
  let topRightSafeArea: CGRect?
  let fullscreenTopInset: CGFloat

  init(
    id: String,
    localizedName: String,
    displayID: CGDirectDisplayID,
    isBuiltIn: Bool,
    frame: CGRect,
    topRightSafeArea: CGRect?,
    fullscreenTopInset: CGFloat = 0
  ) {
    self.id = id
    self.localizedName = localizedName
    self.displayID = displayID
    self.isBuiltIn = isBuiltIn
    self.frame = frame
    self.topRightSafeArea = topRightSafeArea
    self.fullscreenTopInset = fullscreenTopInset
  }

  /// The menu-bar band this display's clock draws inside.
  ///
  /// This is the strip the system menu bar occupies, not the area under it. In a
  /// fullscreen Space the strip is empty, so drawing here puts TimeLedge on the
  /// same line the system clock uses when the menu bar is visible.
  var placementBounds: CGRect {
    if let area = topRightSafeArea, !area.isEmpty {
      return CGRect(
        x: max(area.minX, frame.minX),
        y: max(area.minY, frame.minY),
        width: min(area.width, frame.width),
        height: min(area.height, frame.height)
      )
    }
    return frame
  }

  static func == (lhs: DisplayDescriptor, rhs: DisplayDescriptor) -> Bool {
    lhs.id == rhs.id && lhs.localizedName == rhs.localizedName && lhs.displayID == rhs.displayID
      && lhs.isBuiltIn == rhs.isBuiltIn && lhs.frame == rhs.frame
      && lhs.topRightSafeArea == rhs.topRightSafeArea
      && lhs.fullscreenTopInset == rhs.fullscreenTopInset
  }
}
