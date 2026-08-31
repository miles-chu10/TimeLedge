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
}

public struct DisplayPreference: Codable, Equatable {
  public var isEnabled: Bool
  public var showsBackground: Bool

  public init(isEnabled: Bool, showsBackground: Bool) {
    self.isEnabled = isEnabled
    self.showsBackground = showsBackground
  }
}
