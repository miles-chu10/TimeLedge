import CoreGraphics
import Foundation

public enum WindowCoverage {
  public static func coversDisplay(
    windowBounds: CGRect,
    displayBounds: CGRect,
    minimumCoverage: CGFloat = 0.985,
    edgeTolerance: CGFloat = 3
  ) -> Bool {
    guard displayBounds.width > 0, displayBounds.height > 0 else {
      return false
    }

    let intersection = windowBounds.intersection(displayBounds)
    guard !intersection.isNull, !intersection.isEmpty else {
      return false
    }

    let displayArea = displayBounds.width * displayBounds.height
    let coveredArea = intersection.width * intersection.height
    let coverage = coveredArea / displayArea
    let coversEdges =
      windowBounds.minX <= displayBounds.minX + edgeTolerance
      && windowBounds.maxX >= displayBounds.maxX - edgeTolerance
      && windowBounds.minY <= displayBounds.minY + edgeTolerance
      && windowBounds.maxY >= displayBounds.maxY - edgeTolerance

    return coverage >= minimumCoverage && coversEdges
  }
}
