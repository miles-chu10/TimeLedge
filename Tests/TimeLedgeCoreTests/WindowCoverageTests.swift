import XCTest

@testable import TimeLedgeCore

final class WindowCoverageTests: XCTestCase {
  func testExactFullscreenWindowCoversDisplay() {
    let display = CGRect(x: 0, y: 0, width: 1_512, height: 982)
    XCTAssertTrue(WindowCoverage.coversDisplay(windowBounds: display, displayBounds: display))
  }

  func testOrdinaryWindowDoesNotCoverDisplay() {
    let display = CGRect(x: 0, y: 0, width: 1_512, height: 982)
    let window = CGRect(x: 80, y: 60, width: 1_300, height: 800)
    XCTAssertFalse(WindowCoverage.coversDisplay(windowBounds: window, displayBounds: display))
  }

  func testNearPixelRoundingStillCountsAsFullscreen() {
    let display = CGRect(x: 0, y: 0, width: 1_512, height: 982)
    let window = CGRect(x: -1, y: -1, width: 1_514, height: 984)
    XCTAssertTrue(WindowCoverage.coversDisplay(windowBounds: window, displayBounds: display))
  }

  func testZeroSizedDisplayFailsClosed() {
    XCTAssertFalse(
      WindowCoverage.coversDisplay(windowBounds: .zero, displayBounds: .zero)
    )
  }
}
