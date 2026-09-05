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

  /// Places the clock at the trailing edge of `placementBounds` and centers it
  /// vertically inside those bounds when it fits. Taller content keeps its full
  /// height and overflows downward, never above the physical display top.
  ///
  /// `placementBounds` is the menu-bar band itself, so centering puts the clock
  /// on the same baseline as the system clock. Anchoring below the band's bottom
  /// edge is what previously pushed the overlay a full menu-bar height too low.
  public static func frame(
    in placementBounds: CGRect,
    contentSize: CGSize,
    rightMargin: CGFloat,
    verticalOffset: CGFloat = 0
  ) -> CGRect {
    let safeRightMargin = max(0, rightMargin)
    let availableWidth = maximumContentWidth(
      in: placementBounds,
      rightMargin: safeRightMargin
    )
    let width = min(max(1, contentSize.width), availableWidth).rounded(.up)
    let height = max(1, contentSize.height).rounded(.up)
    let x = placementBounds.maxX - safeRightMargin - width
    let y = placementBounds.midY - height / 2 + verticalOffset
    return CGRect(
      x: max(placementBounds.minX, x).rounded(),
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
