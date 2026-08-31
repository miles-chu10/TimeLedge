import XCTest

@testable import TimeLedgeCore

final class ClockVisibilityTests: XCTestCase {
  private let affirmative = ClockVisibilityEvidence(
    appIsEnabled: true,
    sessionIsActive: true,
    displayIsAvailable: true,
    menuBarIsHiddenByGeometry: true,
    frontmostWindowCoversDisplay: true,
    pointerIsRevealingMenuBar: false
  )

  func testAutomaticShowsForHiddenMenuBarWithoutFullscreenWindow() {
    var evidence = affirmative
    evidence.frontmostWindowCoversDisplay = false

    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testAutomaticFailsClosedForCoverageWithVisibleMenuBar() {
    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false

    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testFullscreenOnlyRequiresHiddenMenuBarAndWindowCoverage() {
    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .fullscreenOnly, evidence: affirmative)
    )

    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false
    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .fullscreenOnly, evidence: evidence)
    )

    evidence.frontmostWindowCoversDisplay = false
    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .fullscreenOnly, evidence: evidence)
    )
  }

  func testAutomaticHidesWithVisibleMenuBarAndOrdinaryWindow() {
    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false
    evidence.frontmostWindowCoversDisplay = false

    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testAlwaysStillFailsClosedWhenSessionIsInactive() {
    var evidence = affirmative
    evidence.sessionIsActive = false

    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .always, evidence: evidence)
    )
  }

  func testPointerRevealSuppressesAutomaticModes() {
    var evidence = affirmative
    evidence.pointerIsRevealingMenuBar = true

    for mode in [ClockVisibilityMode.automatic, .fullscreenOnly] {
      XCTAssertFalse(ClockVisibilityPolicy.shouldShowClock(mode: mode, evidence: evidence))
    }
    XCTAssertTrue(ClockVisibilityPolicy.shouldShowClock(mode: .always, evidence: evidence))
  }

  func testDisabledClockAndMissingDisplayFailClosed() {
    var evidence = affirmative
    evidence.appIsEnabled = false
    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )

    evidence = affirmative
    evidence.displayIsAvailable = false
    XCTAssertFalse(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }
}
