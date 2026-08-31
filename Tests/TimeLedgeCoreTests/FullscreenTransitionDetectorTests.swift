import XCTest

@testable import TimeLedgeCore

final class FullscreenTransitionDetectorTests: XCTestCase {
  private let window = WindowIdentity(ownerProcessIdentifier: 42, windowNumber: 7)

  func testOrdinaryMaximizeWithoutSpaceChangeFailsClosed() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 1),
      []
    )
  }

  func testSpaceTransitionFromRecentWindowedGeometryVerifiesFullscreen() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    detector.noteSpaceChange(at: 1)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2),
      ["built-in"]
    )
  }

  func testCoverageJustBeforeSpaceNotificationStillVerifiesFullscreen() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 1.8)
    detector.noteSpaceChange(at: 2)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2.1),
      ["built-in"]
    )
  }

  func testAlreadyCoveringWindowOnSpaceSwitchFailsClosed() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 0)
    detector.noteSpaceChange(at: 1)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2),
      []
    )
  }

  func testMaximizeBeforeSpaceChangeDoesNotVerifyFullscreen() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 1)
    detector.noteSpaceChange(at: 2)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 3),
      []
    )
  }

  func testVerifiedWindowRemainsVerifiedAfterLeavingAndReturningToItsSpace() {
    var detector = FullscreenTransitionDetector()
    let otherWindow = WindowIdentity(ownerProcessIdentifier: 84, windowNumber: 9)
    _ = detector.update(snapshots: [snapshot()], at: 0)
    detector.noteSpaceChange(at: 1)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2)
    detector.noteSpaceChange(at: 3, previousWindowIdentities: [window])
    _ = detector.update(
      snapshots: [snapshot(identity: otherWindow)],
      at: 3.5
    )
    detector.noteSpaceChange(at: 4, previousWindowIdentities: [otherWindow])

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 5),
      ["built-in"]
    )
  }

  func testSameVerifiedWindowAcrossSpaceChangeIsTreatedAsFullscreenExit() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    detector.noteSpaceChange(at: 1)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2)
    detector.noteSpaceChange(at: 3, previousWindowIdentities: [window])

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 4),
      []
    )
  }

  func testReturningToWindowedGeometryClearsVerification() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    detector.noteSpaceChange(at: 1)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2)
    _ = detector.update(snapshots: [snapshot()], at: 3)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 4),
      []
    )
  }

  private func snapshot(
    identity: WindowIdentity? = nil,
    covering displayIDs: Set<String> = []
  ) -> WindowCoverageSnapshot {
    WindowCoverageSnapshot(
      identity: identity ?? window,
      coveredDisplayIDs: displayIDs
    )
  }
}
