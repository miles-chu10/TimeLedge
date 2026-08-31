import Foundation

public enum ClockFormatter {
  public static func string(
    from date: Date,
    preferences: ClockPreferences,
    locale: Locale = .autoupdatingCurrent,
    timeZone: TimeZone = .autoupdatingCurrent,
    calendar: Calendar = .autoupdatingCurrent
  ) -> String {
    if preferences.customFormatEnabled {
      let pattern = preferences.customFormat.trimmingCharacters(in: .whitespacesAndNewlines)
      if !pattern.isEmpty, pattern.count <= 128 {
        return format(
          date, pattern: pattern, locale: locale, timeZone: timeZone, calendar: calendar)
      }
    }

    var parts: [String] = []
    let dateTemplate = standardDateTemplate(preferences: preferences)
    if !dateTemplate.isEmpty {
      let localizedPattern =
        DateFormatter.dateFormat(fromTemplate: dateTemplate, options: 0, locale: locale)
        ?? dateTemplate
      parts.append(
        format(
          date, pattern: localizedPattern, locale: locale, timeZone: timeZone, calendar: calendar))
    }

    let timeTemplate: String
    if preferences.use24HourFormat {
      timeTemplate = preferences.showSeconds ? "HHmmss" : "HHmm"
    } else {
      timeTemplate = preferences.showSeconds ? "hmmssa" : "hmma"
    }
    let timePattern =
      DateFormatter.dateFormat(fromTemplate: timeTemplate, options: 0, locale: locale)
      ?? timeTemplate
    parts.append(
      format(date, pattern: timePattern, locale: locale, timeZone: timeZone, calendar: calendar))
    return parts.joined(separator: " ")
  }

  public static func updateInterval(preferences: ClockPreferences) -> TimeInterval {
    if preferences.showSeconds || preferences.customFormatEnabled {
      return 1
    }
    return 30
  }

  private static func standardDateTemplate(preferences: ClockPreferences) -> String {
    switch (preferences.showWeekday, preferences.showDate) {
    case (true, true): return "EEEMMMd"
    case (true, false): return "EEE"
    case (false, true): return "MMMd"
    case (false, false): return ""
    }
  }

  private static func format(
    _ date: Date,
    pattern: String,
    locale: Locale,
    timeZone: TimeZone,
    calendar: Calendar
  ) -> String {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.timeZone = timeZone
    formatter.calendar = calendar
    formatter.dateFormat = pattern
    return formatter.string(from: date)
  }
}
