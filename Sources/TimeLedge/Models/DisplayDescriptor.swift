import AppKit
import CoreGraphics

struct DisplayDescriptor: Identifiable, Equatable {
  let id: String
  let localizedName: String
  let displayID: CGDirectDisplayID
  let isBuiltIn: Bool
  let frame: CGRect
  let topRightSafeArea: CGRect?

  var placementBounds: CGRect {
    if let area = topRightSafeArea, !area.isEmpty {
      let topEdge = min(max(frame.minY + 1, area.minY), frame.maxY)
      return CGRect(
        x: area.minX,
        y: frame.minY,
        width: area.width,
        height: topEdge - frame.minY
      )
    }
    return frame
  }

  static func == (lhs: DisplayDescriptor, rhs: DisplayDescriptor) -> Bool {
    lhs.id == rhs.id && lhs.localizedName == rhs.localizedName && lhs.displayID == rhs.displayID
      && lhs.isBuiltIn == rhs.isBuiltIn && lhs.frame == rhs.frame
      && lhs.topRightSafeArea == rhs.topRightSafeArea
  }
}
