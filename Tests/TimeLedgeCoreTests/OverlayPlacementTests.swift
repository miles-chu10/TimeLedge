import XCTest

@testable import TimeLedgeCore

final class OverlayPlacementTests: XCTestCase {
  /// Real geometry measured from the Window Server on a notched MacBook:
  /// screen frame (0, 0, 1512, 982), menu-bar band y 950 → 982.
  private let notchedScreen = CGRect(x: 0, y: 0, width: 1512, height: 982)
  private let notchedBand = CGRect(x: 848.5, y: 950, width: 663.5, height: 32)

  func testCentersClockInsideTheMenuBarBand() {
    let frame = OverlayPlacement.frame(
      in: notchedBand,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12
    )

    XCTAssertEqual(frame, CGRect(x: 1380, y: 958, width: 120, height: 16))
    XCTAssertEqual(frame.midY, notchedBand.midY)
  }

  func testClockNeverFallsBelowTheMenuBarBand() {
    for height in stride(from: CGFloat(10), through: 30, by: 2) {
      let frame = OverlayPlacement.frame(
        in: notchedBand,
        contentSize: CGSize(width: 120, height: height),
        rightMargin: 12
      )

      XCTAssertGreaterThanOrEqual(
        frame.midY,
        notchedBand.minY,
        "clock centre dropped below the band at height \(height)"
      )
      XCTAssertLessThanOrEqual(
        frame.midY,
        notchedBand.maxY,
        "clock centre rose above the band at height \(height)"
      )
    }
  }

  func testOversizedClockPreservesHeightAndOverflowsDownward() {
    // 41 points is the measured 28-point ClockView with background padding.
    for top: CGFloat in [982, 2062, -98, -98.25, 982.75] {
      for bandHeight: CGFloat in [22, 24, 32, 41, 48] {
        for height: CGFloat in [33, 40, 41, 41.25] {
          let band = CGRect(x: -1920, y: top - bandHeight, width: 1920, height: bandHeight)
          let frame = OverlayPlacement.frame(
            in: band, contentSize: CGSize(width: 180, height: height), rightMargin: 12
          )
          XCTAssertEqual(frame.height, height.rounded(.up))
          XCTAssertLessThanOrEqual(frame.maxY, top)
          XCTAssertEqual(frame.maxX, -12)
          if frame.height >= bandHeight {
            XCTAssertLessThanOrEqual(frame.minY, band.minY)
            XCTAssertLessThan(top - frame.maxY, 1)
          } else {
            XCTAssertEqual(frame.midY, band.midY, accuracy: 0.5)
          }
        }
      }
    }
    let historicalFrame = OverlayPlacement.frame(
      in: notchedBand, contentSize: CGSize(width: 180, height: 40), rightMargin: 12
    )
    XCTAssertEqual(historicalFrame, CGRect(x: 1320, y: 942, width: 180, height: 40))
  }

  func testPositiveOffsetCannotPushClockAbovePhysicalTop() {
    let frame = OverlayPlacement.frame(
      in: notchedBand, contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12, verticalOffset: 20
    )
    XCTAssertEqual(frame.maxY, notchedScreen.maxY)
  }

  func testPlacesClockAtTopRightWithinTheRightMargin() {
    let frame = OverlayPlacement.frame(
      in: notchedBand,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12
    )

    XCTAssertEqual(frame.maxX, notchedBand.maxX - 12)
  }

  func testWideRightMarginClearsTheCameraIndicator() {
    let frame = OverlayPlacement.frame(
      in: notchedBand,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 38
    )

    XCTAssertEqual(frame.maxX, notchedBand.maxX - 38)
  }

  func testPreservesNegativeGlobalDisplayCoordinates() {
    let band = OverlayPlacement.menuBarBand(
      screenFrame: CGRect(x: -1920, y: 0, width: 1920, height: 1080),
      bandHeight: 24
    )
    let frame = OverlayPlacement.frame(
      in: band,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12
    )

    XCTAssertEqual(band, CGRect(x: -1920, y: 1056, width: 1920, height: 24))
    XCTAssertEqual(frame, CGRect(x: -132, y: 1060, width: 120, height: 16))
  }

  func testClampsOversizedClockToLeftEdgeOfPlacementArea() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 100, y: 0, width: 80, height: 30),
      contentSize: CGSize(width: 140, height: 20),
      rightMargin: 12
    )

    XCTAssertEqual(frame.minX, 100)
    XCTAssertEqual(frame.width, 68)
    XCTAssertEqual(frame.maxX, 168)
  }

  func testVerticalOffsetNudgesTheClockWithoutLeavingTheBand() {
    let frame = OverlayPlacement.frame(
      in: notchedBand,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12,
      verticalOffset: -2
    )

    XCTAssertEqual(frame.origin.y, 956)
  }

  func testMaximumContentWidthAccountsForBackgroundPadding() {
    XCTAssertEqual(
      OverlayPlacement.maximumContentWidth(
        in: CGRect(x: 100, y: 0, width: 80, height: 30),
        rightMargin: 12,
        horizontalPadding: 16
      ),
      52
    )
  }

  func testCentersClockOnNonNotchedExternalDisplayBand() {
    let screen = CGRect(x: -226, y: 982, width: 1920, height: 1080)
    let band = OverlayPlacement.menuBarBand(screenFrame: screen, bandHeight: 30)
    let frame = OverlayPlacement.frame(
      in: band,
      contentSize: CGSize(width: 120, height: 16),
      rightMargin: 12
    )

    XCTAssertEqual(band, CGRect(x: -226, y: 2032, width: 1920, height: 30))
    XCTAssertEqual(frame.midY, band.midY)
    XCTAssertGreaterThanOrEqual(frame.minY, band.minY)
    XCTAssertLessThanOrEqual(frame.maxY, band.maxY)
  }

  func testMenuBarBandSitsAtTheVeryTopOfTheScreen() {
    let band = OverlayPlacement.menuBarBand(
      screenFrame: notchedScreen,
      bandHeight: 32
    )

    XCTAssertEqual(band, CGRect(x: 0, y: 950, width: 1512, height: 32))
    XCTAssertEqual(band.maxY, notchedScreen.maxY)
  }

  func testMenuBarBandRespectsANotchSafeLeftEdge() {
    let band = OverlayPlacement.menuBarBand(
      screenFrame: notchedScreen,
      bandHeight: 32,
      minimumX: notchedScreen.midX
    )

    XCTAssertEqual(band, CGRect(x: 756, y: 950, width: 756, height: 32))
  }

  func testMenuBarBandNeverExceedsTheScreenHeight() {
    let band = OverlayPlacement.menuBarBand(
      screenFrame: CGRect(x: 0, y: 0, width: 100, height: 20),
      bandHeight: 400
    )

    XCTAssertEqual(band, CGRect(x: 0, y: 0, width: 100, height: 20))
  }
}
