import CoreGraphics
import Foundation

/// Where the clock sits inside its placement band.
public enum OverlayVerticalAlignment: String, Sendable {
  /// Centered in the band. Used for the freed menu-bar strip, so the clock
  /// lands where the system clock would have been.
  case centered
  /// Pinned under the top edge of the band. Used when the real menu bar is on
  /// screen and the clock has to stay clear of it.
  case top
}

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
    topMargin: CGFloat = 3,
    alignment: OverlayVerticalAlignment = .top
  ) -> CGRect {
    let safeRightMargin = max(0, rightMargin)
    let availableWidth = maximumContentWidth(
      in: placementBounds,
      rightMargin: safeRightMargin
    )
    let width = min(max(1, contentSize.width), availableWidth)
    let height = max(1, contentSize.height)
    let x = placementBounds.maxX - safeRightMargin - width
    let y: CGFloat
    switch alignment {
    case .centered where height <= placementBounds.height:
      y = placementBounds.midY - height / 2
    case .centered, .top:
      y = placementBounds.maxY - topMargin - height
    }
    return CGRect(
      x: max(placementBounds.minX, x),
      y: y,
      width: width,
      height: height
    ).integral
  }
}
