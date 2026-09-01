import Foundation

public enum ClockFontFamily: String, CaseIterable, Codable, Identifiable {
  case system
  case rounded
  case monospaced

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .system: return "SF Pro"
    case .rounded: return "SF Rounded"
    case .monospaced: return "SF Mono"
    }
  }
}

public enum ClockFontWeight: String, CaseIterable, Codable, Identifiable {
  case regular
  case medium
  case semibold
  case bold

  public var id: String { rawValue }
  public var title: String { rawValue.capitalized }
}

public enum ClockTextColor: String, CaseIterable, Codable, Identifiable {
  case adaptive
  case white
  case black

  public var id: String { rawValue }
  public var title: String { rawValue.capitalized }
}

public enum ClockRightMargin: String, CaseIterable, Codable, Identifiable {
  case standard
  case wide

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .standard: return "Default"
    case .wide: return "Wide"
    }
  }

  public var points: Double {
    switch self {
    case .standard: return 12
    case .wide: return 38
    }
  }
}

public enum ClockWindowLayer: String, CaseIterable, Codable, Identifiable {
  case overApps
  case behindApps

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .overApps: return "Over Apps"
    case .behindApps: return "Behind Apps"
    }
  }
}

public struct ClockPreferences: Codable, Equatable {
  public var isClockVisible: Bool
  /// Opt-in text clock in the real menu bar. Off by default: macOS already
  /// shows a menu-bar clock there, and a second one is pure duplication.
  public var showsMenuBarClock: Bool
  public var use24HourFormat: Bool
  public var showSeconds: Bool
  public var showDate: Bool
  public var showWeekday: Bool
  public var customFormatEnabled: Bool
  public var customFormat: String
  public var fontFamily: ClockFontFamily
  public var fontWeight: ClockFontWeight
  public var fontSize: Double
  public var textColor: ClockTextColor
  public var textOpacity: Double
  public var backgroundOpacity: Double
  public var rightMargin: ClockRightMargin
  public var windowLayer: ClockWindowLayer
  public var launchAtLogin: Bool

  public init(
    isClockVisible: Bool = true,
    showsMenuBarClock: Bool = false,
    use24HourFormat: Bool = false,
    showSeconds: Bool = false,
    showDate: Bool = true,
    showWeekday: Bool = true,
    customFormatEnabled: Bool = false,
    customFormat: String = "'Week' w, EEEE HH:mm",
    fontFamily: ClockFontFamily = .system,
    fontWeight: ClockFontWeight = .regular,
    fontSize: Double = 13,
    textColor: ClockTextColor = .adaptive,
    textOpacity: Double = 1,
    backgroundOpacity: Double = 0.55,
    rightMargin: ClockRightMargin = .standard,
    windowLayer: ClockWindowLayer = .overApps,
    launchAtLogin: Bool = false
  ) {
    self.isClockVisible = isClockVisible
    self.showsMenuBarClock = showsMenuBarClock
    self.use24HourFormat = use24HourFormat
    self.showSeconds = showSeconds
    self.showDate = showDate
    self.showWeekday = showWeekday
    self.customFormatEnabled = customFormatEnabled
    self.customFormat = customFormat
    self.fontFamily = fontFamily
    self.fontWeight = fontWeight
    self.fontSize = fontSize
    self.textColor = textColor
    self.textOpacity = textOpacity
    self.backgroundOpacity = backgroundOpacity
    self.rightMargin = rightMargin
    self.windowLayer = windowLayer
    self.launchAtLogin = launchAtLogin
  }

  public static let defaults = ClockPreferences()

  private enum CodingKeys: String, CodingKey {
    case isClockVisible
    case showsMenuBarClock
    case use24HourFormat
    case showSeconds
    case showDate
    case showWeekday
    case customFormatEnabled
    case customFormat
    case fontFamily
    case fontWeight
    case fontSize
    case textColor
    case textOpacity
    case backgroundOpacity
    case rightMargin
    case windowLayer
    case launchAtLogin
  }

  /// Decodes tolerantly so that preferences written by an older build -- which
  /// has no entry for a key added later -- keep every setting the user chose
  /// instead of resetting the whole record to defaults.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let fallback = ClockPreferences()
    func decode<T: Decodable>(_ key: CodingKeys, or defaultValue: T) throws -> T {
      try container.decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }

    self.init(
      isClockVisible: try decode(.isClockVisible, or: fallback.isClockVisible),
      showsMenuBarClock: try decode(.showsMenuBarClock, or: fallback.showsMenuBarClock),
      use24HourFormat: try decode(.use24HourFormat, or: fallback.use24HourFormat),
      showSeconds: try decode(.showSeconds, or: fallback.showSeconds),
      showDate: try decode(.showDate, or: fallback.showDate),
      showWeekday: try decode(.showWeekday, or: fallback.showWeekday),
      customFormatEnabled: try decode(.customFormatEnabled, or: fallback.customFormatEnabled),
      customFormat: try decode(.customFormat, or: fallback.customFormat),
      fontFamily: try decode(.fontFamily, or: fallback.fontFamily),
      fontWeight: try decode(.fontWeight, or: fallback.fontWeight),
      fontSize: try decode(.fontSize, or: fallback.fontSize),
      textColor: try decode(.textColor, or: fallback.textColor),
      textOpacity: try decode(.textOpacity, or: fallback.textOpacity),
      backgroundOpacity: try decode(.backgroundOpacity, or: fallback.backgroundOpacity),
      rightMargin: try decode(.rightMargin, or: fallback.rightMargin),
      windowLayer: try decode(.windowLayer, or: fallback.windowLayer),
      launchAtLogin: try decode(.launchAtLogin, or: fallback.launchAtLogin)
    )
  }
}

public struct DisplayPreference: Codable, Equatable {
  public var isEnabled: Bool
  public var showsBackground: Bool

  public init(isEnabled: Bool, showsBackground: Bool) {
    self.isEnabled = isEnabled
    self.showsBackground = showsBackground
  }
}
