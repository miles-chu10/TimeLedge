import XCTest

@testable import TimeLedgeCore

final class ClockPreferencesTests: XCTestCase {
  func testPreferencesRoundTripThroughJSON() throws {
    var original = ClockPreferences.defaults
    original.use24HourFormat = false
    original.showSeconds = true
    original.customFormatEnabled = true
    original.customFormat = "EEEE HH:mm:ss"
    original.fontFamily = .rounded
    original.fontWeight = .semibold
    original.fontSize = 19
    original.textColor = .white
    original.textOpacity = 0.75
    original.backgroundOpacity = 0.4
    original.rightMargin = .wide
    original.windowLayer = .behindApps

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(ClockPreferences.self, from: data)
    XCTAssertEqual(decoded, original)
  }

  func testDefaultsPrioritizeBuiltInFullscreenUse() {
    let preferences = ClockPreferences.defaults
    XCTAssertTrue(preferences.isClockVisible)
    XCTAssertFalse(preferences.use24HourFormat)
    XCTAssertEqual(preferences.windowLayer, .overApps)
    XCTAssertEqual(preferences.rightMargin, .standard)
    XCTAssertFalse(preferences.launchAtLogin)
  }
}
