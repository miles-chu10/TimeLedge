import XCTest

@testable import TimeLedgeCore

final class ClockFormatterTests: XCTestCase {
  private let locale = Locale(identifier: "en_US_POSIX")
  private let timeZone = TimeZone(secondsFromGMT: 0)!
  private var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar
  }

  private var date: Date {
    DateComponents(
      calendar: calendar,
      timeZone: timeZone,
      year: 2025,
      month: 6,
      day: 14,
      hour: 9,
      minute: 5,
      second: 7
    ).date!
  }

  func testTwentyFourHourTimeWithoutDate() {
    var preferences = ClockPreferences.defaults
    preferences.showDate = false
    preferences.showWeekday = false
    preferences.use24HourFormat = true

    XCTAssertEqual(
      ClockFormatter.string(
        from: date,
        preferences: preferences,
        locale: locale,
        timeZone: timeZone,
        calendar: calendar
      ),
      "09:05"
    )
  }

  func testTwelveHourTimeWithSeconds() {
    var preferences = ClockPreferences.defaults
    preferences.showDate = false
    preferences.showWeekday = false
    preferences.use24HourFormat = false
    preferences.showSeconds = true

    let value = ClockFormatter.string(
      from: date,
      preferences: preferences,
      locale: locale,
      timeZone: timeZone,
      calendar: calendar
    )
    XCTAssertEqual(value.replacingOccurrences(of: "\u{202F}", with: " "), "9:05:07 AM")
  }

  func testCustomFormatUsesExactPattern() {
    var preferences = ClockPreferences.defaults
    preferences.customFormatEnabled = true
    preferences.customFormat = "'Week' w, EEEE HH:mm"

    XCTAssertEqual(
      ClockFormatter.string(
        from: date,
        preferences: preferences,
        locale: locale,
        timeZone: timeZone,
        calendar: calendar
      ),
      "Week 24, Saturday 09:05"
    )
  }

  func testBlankCustomFormatFallsBackToStandardFormat() {
    var preferences = ClockPreferences.defaults
    preferences.customFormatEnabled = true
    preferences.customFormat = "   "
    preferences.showDate = false
    preferences.showWeekday = false

    let value = ClockFormatter.string(
      from: date,
      preferences: preferences,
      locale: locale,
      timeZone: timeZone,
      calendar: calendar
    )
    XCTAssertEqual(value.replacingOccurrences(of: "\u{202F}", with: " "), "9:05 AM")
  }

  func testOverlongCustomFormatFallsBackToStandardFormat() {
    var preferences = ClockPreferences.defaults
    preferences.customFormatEnabled = true
    preferences.customFormat = String(repeating: "x", count: 129)
    preferences.showDate = false
    preferences.showWeekday = false

    let value = ClockFormatter.string(
      from: date,
      preferences: preferences,
      locale: locale,
      timeZone: timeZone,
      calendar: calendar
    )
    XCTAssertEqual(value.replacingOccurrences(of: "\u{202F}", with: " "), "9:05 AM")
  }

  func testUpdateIntervalTracksSecondsAndCustomFormats() {
    var preferences = ClockPreferences.defaults
    XCTAssertEqual(ClockFormatter.updateInterval(preferences: preferences), 30)

    preferences.showSeconds = true
    XCTAssertEqual(ClockFormatter.updateInterval(preferences: preferences), 1)

    preferences.showSeconds = false
    preferences.customFormatEnabled = true
    XCTAssertEqual(ClockFormatter.updateInterval(preferences: preferences), 1)
  }
}
