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

  func testAutomaticShowsForFullDisplayWindowCoverage() {
    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false

    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testAutomaticShowsWheneverTheMenuBarWindowIsOffScreen() {
    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false
    evidence.frontmostWindowCoversDisplay = false
    evidence.menuBarWindowIsVisible = false

    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testVisibleMenuBarWindowOutranksFullDisplayCoverage() {
    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false
    evidence.menuBarWindowIsVisible = true

    for mode in [ClockVisibilityMode.automatic, .fullscreenOnly] {
      XCTAssertFalse(ClockVisibilityPolicy.shouldShowClock(mode: mode, evidence: evidence))
    }
  }

  func testHiddenMenuBarGeometryStillWinsWhenTheProbeDisagrees() {
    var evidence = affirmative
    evidence.menuBarWindowIsVisible = true
    evidence.frontmostWindowCoversDisplay = false

    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .automatic, evidence: evidence)
    )
  }

  func testFullscreenOnlyRequiresVerifiedWindowCoverage() {
    XCTAssertTrue(
      ClockVisibilityPolicy.shouldShowClock(mode: .fullscreenOnly, evidence: affirmative)
    )

    var evidence = affirmative
    evidence.menuBarIsHiddenByGeometry = false
    XCTAssertTrue(
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
