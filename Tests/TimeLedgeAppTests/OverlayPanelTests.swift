import AppKit
import XCTest

@testable import TimeLedge

@MainActor
final class OverlayPanelTests: XCTestCase {
  func testDoesNotConstrainOverlayBelowVisibleMenuBar() {
    let panel = OverlayPanel()
    let requestedFrame = CGRect(x: 1200, y: 960, width: 200, height: 20)

    XCTAssertEqual(
      panel.constrainFrameRect(requestedFrame, to: NSScreen.main),
      requestedFrame
    )
  }
}
