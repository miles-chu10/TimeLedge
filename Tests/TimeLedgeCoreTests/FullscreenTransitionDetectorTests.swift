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

  func testAlreadyCoveringWindowOnSpaceSwitchFailsClosed() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 0)
    detector.noteSpaceChange(at: 1)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2),
      []
    )
  }

  func testVerifiedWindowRemainsVerifiedAfterLeavingAndReturningToItsSpace() {
    var detector = FullscreenTransitionDetector()
    _ = detector.update(snapshots: [snapshot()], at: 0)
    detector.noteSpaceChange(at: 1)
    _ = detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 2)
    _ = detector.update(snapshots: [], at: 3)

    XCTAssertEqual(
      detector.update(snapshots: [snapshot(covering: ["built-in"])], at: 4),
      ["built-in"]
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

  private func snapshot(covering displayIDs: Set<String> = []) -> WindowCoverageSnapshot {
    WindowCoverageSnapshot(identity: window, coveredDisplayIDs: displayIDs)
  }
}
