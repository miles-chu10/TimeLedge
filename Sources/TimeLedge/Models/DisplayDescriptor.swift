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

  /// The band the clock is laid out in.
  ///
  /// While the menu bar is hidden the clock takes over the strip the menu bar
  /// vacated, which is where a menu-bar clock belongs and which keeps it off
  /// the app's own content. While the menu bar is on screen the band stops
  /// below the strip, because the overlay renders under the real menu bar.
  func placementBounds(menuBarIsVisible: Bool) -> CGRect {
    guard let area = topRightSafeArea, !area.isEmpty else {
      return frame
    }
    guard menuBarIsVisible else {
      return area
    }
    let topEdge = min(max(frame.minY + 1, area.minY), frame.maxY)
    return CGRect(
      x: area.minX,
      y: frame.minY,
      width: area.width,
      height: topEdge - frame.minY
    )
  }

  static func == (lhs: DisplayDescriptor, rhs: DisplayDescriptor) -> Bool {
    lhs.id == rhs.id && lhs.localizedName == rhs.localizedName && lhs.displayID == rhs.displayID
      && lhs.isBuiltIn == rhs.isBuiltIn && lhs.frame == rhs.frame
      && lhs.topRightSafeArea == rhs.topRightSafeArea
      && lhs.fullscreenTopInset == rhs.fullscreenTopInset
  }
}
