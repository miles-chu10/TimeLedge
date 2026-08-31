import CoreGraphics
import Foundation

public enum OverlayPlacement {
  public static func maximumContentWidth(
    in placementBounds: CGRect,
    rightMargin: CGFloat,
    horizontalPadding: CGFloat = 0
  ) -> CGFloat {
    max(1, placementBounds.width - max(0, rightMargin) - max(0, horizontalPadding))
  }

  public static func frame(
    in placementBounds: CGRect,
    contentSize: CGSize,
    rightMargin: CGFloat,
    topMargin: CGFloat = 3
  ) -> CGRect {
    let safeRightMargin = max(0, rightMargin)
    let availableWidth = maximumContentWidth(
      in: placementBounds,
      rightMargin: safeRightMargin
    )
    let width = min(max(1, contentSize.width), availableWidth)
    let height = max(1, contentSize.height)
    let x = placementBounds.maxX - safeRightMargin - width
    let y = placementBounds.maxY - topMargin - height
    return CGRect(
      x: max(placementBounds.minX, x),
      y: y,
      width: width,
      height: height
    ).integral
  }
}
