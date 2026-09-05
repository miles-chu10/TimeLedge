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

  /// Places the clock at the trailing edge of its band. Centered content that
  /// fits uses the band's midpoint; top-aligned or taller content uses the top
  /// anchor. The full measured height stays below the physical display top.
  public static func frame(
    in placementBounds: CGRect,
    contentSize: CGSize,
    rightMargin: CGFloat,
    verticalOffset: CGFloat = 0,
    topMargin: CGFloat = 3,
    alignment: OverlayVerticalAlignment = .top
  ) -> CGRect {
    let safeRightMargin = max(0, rightMargin)
    let availableWidth = maximumContentWidth(
      in: placementBounds,
      rightMargin: safeRightMargin
    )
    let width = min(max(1, contentSize.width).rounded(.up), availableWidth.rounded(.down))
    let height = max(1, contentSize.height).rounded(.up)
    let x = placementBounds.maxX - safeRightMargin - width
    let y: CGFloat
    switch alignment {
    case .centered where height <= placementBounds.height:
      y = placementBounds.midY - height / 2 + verticalOffset
    case .centered, .top:
      y = placementBounds.maxY - topMargin - height + verticalOffset
    }
    return CGRect(
      x: max(placementBounds.minX, x),
      // Clamp after rounding so fractional global coordinates cannot push the
      // top edge off-screen. Preserve the measured height and chosen style.
      y: min(y.rounded(), (placementBounds.maxY - height).rounded(.down)),
      width: width,
      height: height
    )
  }

  /// The menu-bar band for a display, given the best available band height.
  ///
  /// The band is the strip the system menu bar occupies at the top of the
  /// display; in a fullscreen Space it is empty and the clock draws there.
  public static func menuBarBand(
    screenFrame: CGRect,
    bandHeight: CGFloat,
    minimumX: CGFloat? = nil
  ) -> CGRect {
    let height = min(max(1, bandHeight), screenFrame.height)
    let originX = min(max(minimumX ?? screenFrame.minX, screenFrame.minX), screenFrame.maxX - 1)
    return CGRect(
      x: originX,
      y: screenFrame.maxY - height,
      width: screenFrame.maxX - originX,
      height: height
    )
  }
}
