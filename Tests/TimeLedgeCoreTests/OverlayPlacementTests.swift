import XCTest

@testable import TimeLedgeCore

final class OverlayPlacementTests: XCTestCase {
  func testPlacesClockAtTopRightWithMargins() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 0, y: 0, width: 1440, height: 900),
      contentSize: CGSize(width: 120, height: 22),
      rightMargin: 12,
      topMargin: 3
    )

    XCTAssertEqual(frame, CGRect(x: 1308, y: 875, width: 120, height: 22))
  }

  func testPreservesNegativeGlobalDisplayCoordinates() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: -1920, y: 0, width: 1920, height: 1080),
      contentSize: CGSize(width: 120, height: 22),
      rightMargin: 12,
      topMargin: 3
    )

    XCTAssertEqual(frame, CGRect(x: -132, y: 1055, width: 120, height: 22))
  }

  func testUsesNotchSafeTopRightAreaWhenProvided() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 1200, y: 960, width: 240, height: 40),
      contentSize: CGSize(width: 100, height: 20),
      rightMargin: 12,
      topMargin: 3
    )

    XCTAssertEqual(frame, CGRect(x: 1328, y: 977, width: 100, height: 20))
  }

  func testClampsOversizedClockToLeftEdgeOfPlacementArea() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 100, y: 0, width: 80, height: 30),
      contentSize: CGSize(width: 140, height: 20),
      rightMargin: 12,
      topMargin: 3
    )

    XCTAssertEqual(frame.minX, 100)
    XCTAssertEqual(frame.width, 68)
    XCTAssertEqual(frame.maxX, 168)
  }

  func testPreservesTallClockBelowTopStripInsteadOfClippingIt() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 848.5, y: 950, width: 663.5, height: 32),
      contentSize: CGSize(width: 180, height: 40),
      rightMargin: 12,
      topMargin: 3
    )

    XCTAssertEqual(frame, CGRect(x: 1320, y: 939, width: 180, height: 40))
  }

  func testCentersClockInsideTheFreedMenuBarStrip() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 848.5, y: 950, width: 663.5, height: 32),
      contentSize: CGSize(width: 131, height: 16),
      rightMargin: 12,
      alignment: .centered
    )

    XCTAssertEqual(frame, CGRect(x: 1369, y: 958, width: 131, height: 16))
  }

  func testCenteredClockTallerThanTheStripFallsBackToTheTopAnchor() {
    let frame = OverlayPlacement.frame(
      in: CGRect(x: 848.5, y: 950, width: 663.5, height: 32),
      contentSize: CGSize(width: 180, height: 40),
      rightMargin: 12,
      alignment: .centered
    )

    XCTAssertEqual(frame, CGRect(x: 1320, y: 939, width: 180, height: 40))
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
}
