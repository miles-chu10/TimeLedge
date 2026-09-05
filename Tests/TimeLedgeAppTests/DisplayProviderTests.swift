import AppKit
import XCTest

@testable import TimeLedge

@MainActor
final class DisplayProviderTests: XCTestCase {
  func testObservedBandUsesTheVisibleMenuBarGap() {
    let screen = CGRect(x: -1920, y: 0, width: 1920, height: 1080)
    let visible = CGRect(x: -1920, y: 0, width: 1920, height: 1050)
    XCTAssertEqual(
      SystemDisplayProvider.observedMenuBarHeight(screenFrame: screen, visibleFrame: visible),
      30)
    XCTAssertEqual(
      SystemDisplayProvider.observedMenuBarHeight(screenFrame: screen, visibleFrame: screen),
      0)
  }

  func testExternalDisplayUsesLearnedBandInsteadOfStatusItemThickness() {
    let frame = CGRect(x: -1920, y: 0, width: 1920, height: 1080)
    let band = SystemDisplayProvider.topRightPlacementBounds(
      screenFrame: frame, safeAreaTop: 0, statusBarThickness: 22, menuBarHeight: 30,
      auxiliaryTopRightArea: nil)
    XCTAssertEqual(band, CGRect(x: -1920, y: 1050, width: 1920, height: 30))
  }

  func testNotchSafeAreaRemainsRightAlignedWithinTheDisplay() {
    let frame = CGRect(x: 0, y: 0, width: 1512, height: 982)
    let band = SystemDisplayProvider.topRightPlacementBounds(
      screenFrame: frame, safeAreaTop: 32, statusBarThickness: 22, menuBarHeight: 30,
      auxiliaryTopRightArea: CGRect(x: 848.5, y: 950, width: 663.5, height: 32))
    XCTAssertEqual(band, CGRect(x: 848.5, y: 950, width: 663.5, height: 32))
  }
}
