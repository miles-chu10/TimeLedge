import XCTest

@testable import TimeLedgeCore

final class MenuBarPresenceTests: XCTestCase {
  private let builtIn = MenuBarDisplaySample(
    id: "built-in",
    bounds: CGRect(x: 0, y: 0, width: 1512, height: 982)
  )
  private let external = MenuBarDisplaySample(
    id: "external",
    bounds: CGRect(x: 1512, y: 0, width: 1920, height: 1080)
  )

  func testUncalibratedDisplayReportsUnknownRatherThanHidden() {
    var tracker = MenuBarPresenceTracker()

    XCTAssertNil(tracker.update(menuBarWindows: [], displays: [builtIn])["built-in"])
  }

  func testMenuBarStripOnTopEdgeCountsAsVisible() {
    var tracker = MenuBarPresenceTracker()

    let presence = tracker.update(
      menuBarWindows: [menuBar(x: 0, width: 1512, height: 37)],
      displays: [builtIn]
    )

    XCTAssertEqual(presence["built-in"], true)
  }

  func testCalibratedDisplayReportsHiddenWhenTheStripLeavesTheScreen() {
    var tracker = MenuBarPresenceTracker()
    _ = tracker.update(
      menuBarWindows: [menuBar(x: 0, width: 1512, height: 24)],
      displays: [builtIn]
    )

    XCTAssertEqual(tracker.update(menuBarWindows: [], displays: [builtIn])["built-in"], false)
  }

  func testCalibrationIsTrackedPerDisplay() {
    var tracker = MenuBarPresenceTracker()

    let presence = tracker.update(
      menuBarWindows: [menuBar(x: 0, width: 1512, height: 24)],
      displays: [builtIn, external]
    )

    XCTAssertEqual(presence["built-in"], true)
    XCTAssertNil(presence["external"])
  }

  func testTallOrNarrowOrTransparentWindowsAreNotTheMenuBar() {
    var tracker = MenuBarPresenceTracker()
    let windows = [
      menuBar(x: 0, width: 1512, height: 400),
      menuBar(x: 1200, width: 200, height: 24),
      menuBar(x: 0, width: 1512, height: 24, alpha: 0),
      MenuBarWindowSample(bounds: CGRect(x: 0, y: 200, width: 1512, height: 24)),
    ]

    XCTAssertNil(tracker.update(menuBarWindows: windows, displays: [builtIn])["built-in"])
  }

  func testUnreadableWindowListRepeatsTheLastAnswerInsteadOfClaimingHidden() {
    var tracker = MenuBarPresenceTracker()
    _ = tracker.update(
      menuBarWindows: [menuBar(x: 0, width: 1512, height: 24)],
      displays: [builtIn]
    )

    XCTAssertEqual(tracker.update(menuBarWindows: nil, displays: [builtIn])["built-in"], true)
    XCTAssertEqual(tracker.update(menuBarWindows: [], displays: [builtIn])["built-in"], false)
    XCTAssertEqual(tracker.update(menuBarWindows: nil, displays: [builtIn])["built-in"], false)
  }

  func testUnreadableWindowListBeforeCalibrationStaysUnknown() {
    var tracker = MenuBarPresenceTracker()

    XCTAssertNil(tracker.update(menuBarWindows: nil, displays: [builtIn])["built-in"])
  }

  func testDisconnectedDisplaysLoseCalibration() {
    var tracker = MenuBarPresenceTracker()
    _ = tracker.update(
      menuBarWindows: [menuBar(x: 0, width: 1512, height: 24)],
      displays: [builtIn]
    )

    tracker.retainCalibration(for: ["external"])

    XCTAssertNil(tracker.update(menuBarWindows: [], displays: [builtIn])["built-in"])
  }

  private func menuBar(
    x: CGFloat,
    width: CGFloat,
    height: CGFloat,
    alpha: Double = 1
  ) -> MenuBarWindowSample {
    MenuBarWindowSample(
      bounds: CGRect(x: x, y: 0, width: width, height: height),
      alpha: alpha
    )
  }
}
