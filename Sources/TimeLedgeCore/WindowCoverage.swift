import CoreGraphics
import Foundation

public enum WindowCoverage {
  public static func coversDisplay(
    windowBounds: CGRect,
    displayBounds: CGRect,
    allowedTopInset: CGFloat = 0,
    minimumCoverage: CGFloat = 0.985,
    edgeTolerance: CGFloat = 3
  ) -> Bool {
    guard displayBounds.width > 0, displayBounds.height > 0 else {
      return false
    }

    let safeTopInset = min(max(0, allowedTopInset), displayBounds.height - 1)
    let requiredBounds = CGRect(
      x: displayBounds.minX,
      y: displayBounds.minY + safeTopInset,
      width: displayBounds.width,
      height: displayBounds.height - safeTopInset
    )
    let intersection = windowBounds.intersection(requiredBounds)
    guard !intersection.isNull, !intersection.isEmpty else {
      return false
    }

    let displayArea = requiredBounds.width * requiredBounds.height
    let coveredArea = intersection.width * intersection.height
    let coverage = coveredArea / displayArea
    let coversEdges =
      windowBounds.minX <= requiredBounds.minX + edgeTolerance
      && windowBounds.maxX >= requiredBounds.maxX - edgeTolerance
      && windowBounds.minY <= requiredBounds.minY + edgeTolerance
      && windowBounds.maxY >= requiredBounds.maxY - edgeTolerance

    return coverage >= minimumCoverage && coversEdges
  }
}
