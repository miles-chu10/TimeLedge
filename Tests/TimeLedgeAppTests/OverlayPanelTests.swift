import AppKit
import XCTest

@testable import TimeLedge

@MainActor
final class OverlayPanelTests: XCTestCase {
  func testJoinsOtherApplicationsFullscreenSpaces() {
    let behavior = OverlayPanel().collectionBehavior

    XCTAssertTrue(behavior.contains(.canJoinAllSpaces))
    XCTAssertTrue(behavior.contains(.canJoinAllApplications))
    XCTAssertTrue(behavior.contains(.fullScreenAuxiliary))
  }

  func testDoesNotConstrainOverlayBelowVisibleMenuBar() {
    let panel = OverlayPanel()
    let requestedFrame = CGRect(x: 1200, y: 960, width: 200, height: 20)
    panel.setOverlayFrame(requestedFrame, display: false)

    XCTAssertEqual(
      panel.constrainFrameRect(
        CGRect(x: 400, y: 900, width: 200, height: 20),
        to: NSScreen.main
      ),
      requestedFrame
    )
  }
}
