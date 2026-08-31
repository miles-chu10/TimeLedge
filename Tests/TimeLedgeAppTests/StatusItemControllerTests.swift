import XCTest

@testable import TimeLedge
@testable import TimeLedgeCore

@MainActor
final class StatusItemControllerTests: XCTestCase {
  func testVisibleClockUsesTheSharedFormatter() {
    let date = Date(timeIntervalSince1970: 1_000_000)
    let preferences = ClockPreferences.defaults

    XCTAssertEqual(
      StatusItemController.menuBarTitle(
        at: date,
        preferences: preferences,
        isClockVisible: true
      ),
      ClockFormatter.string(from: date, preferences: preferences)
    )
  }

  func testHiddenClockFallsBackToRecoveryIcon() {
    XCTAssertNil(
      StatusItemController.menuBarTitle(
        at: Date(),
        preferences: .defaults,
        isClockVisible: false
      )
    )
  }
}
