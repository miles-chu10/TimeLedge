import XCTest

@testable import TimeLedge
@testable import TimeLedgeCore

@MainActor
final class StatusItemControllerTests: XCTestCase {
  func testControllerKeepsTheRecoveryItemVisible() {
    let defaults = UserDefaults(suiteName: "TimeLedgeTests.\(UUID().uuidString)")!
    let controller = StatusItemController(
      store: PreferencesStore(defaults: defaults),
      onOpenSettings: {},
      onSetLaunchAtLogin: { _ in }
    )

    XCTAssertTrue(controller.isStatusItemVisible)
    controller.stop()
  }

  func testMenuBarStaysIconOnlyByDefaultInsteadOfRepeatingTheSystemClock() {
    XCTAssertFalse(ClockPreferences.defaults.showsMenuBarClock)
    XCTAssertNil(
      StatusItemController.menuBarTitle(
        at: Date(),
        preferences: .defaults,
        isClockVisible: true
      )
    )
  }

  func testOptedInMenuBarClockUsesTheSharedFormatter() {
    let date = Date(timeIntervalSince1970: 1_000_000)
    var preferences = ClockPreferences.defaults
    preferences.showsMenuBarClock = true

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
    var preferences = ClockPreferences.defaults
    preferences.showsMenuBarClock = true

    XCTAssertNil(
      StatusItemController.menuBarTitle(
        at: Date(),
        preferences: preferences,
        isClockVisible: false
      )
    )
  }
}
