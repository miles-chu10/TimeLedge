import Combine
import Foundation
import TimeLedgeCore

@MainActor
final class PreferencesStore: ObservableObject {
  private enum Keys {
    static let preferences = "TimeLedge.preferences.v1"
    static let displays = "TimeLedge.displays.v1"
    static let visibilityMode = "TimeLedge.visibilityMode.v1"
  }

  @Published var preferences: ClockPreferences {
    didSet {
      persistPreferences()
      changeHandler?()
    }
  }

  @Published private(set) var displays: [DisplayDescriptor] = []

  @Published private(set) var displayPreferences: [String: DisplayPreference] {
    didSet {
      persistDisplayPreferences()
      changeHandler?()
    }
  }

  @Published var visibilityMode: ClockVisibilityMode {
    didSet {
      defaults.set(visibilityMode.rawValue, forKey: Keys.visibilityMode)
      changeHandler?()
    }
  }

  @Published var loginItemError: String?

  var changeHandler: (() -> Void)?

  private let defaults: UserDefaults
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults

    if let data = defaults.data(forKey: Keys.preferences),
      let decoded = try? decoder.decode(ClockPreferences.self, from: data)
    {
      preferences = decoded
    } else {
      preferences = .defaults
    }

    if let data = defaults.data(forKey: Keys.displays),
      let decoded = try? decoder.decode([String: DisplayPreference].self, from: data)
    {
      displayPreferences = decoded
    } else {
      displayPreferences = [:]
    }

    visibilityMode =
      ClockVisibilityMode(rawValue: defaults.string(forKey: Keys.visibilityMode) ?? "")
      ?? .automatic
  }

  func synchronize(displays descriptors: [DisplayDescriptor]) {
    displays = descriptors
    var updated = displayPreferences
    let hasBuiltIn = descriptors.contains(where: { $0.isBuiltIn })

    // A laptop enables its built-in display and leaves extra monitors opt-in.
    // A desktop Mac has no built-in display, so its externals are its only
    // displays and all of them are enabled.
    for descriptor in descriptors where updated[descriptor.id] == nil {
      let shouldEnable = descriptor.isBuiltIn || !hasBuiltIn
      updated[descriptor.id] = DisplayPreference(
        isEnabled: shouldEnable,
        showsBackground: false
      )
    }

    if updated != displayPreferences {
      displayPreferences = updated
    }
  }

  func preference(for displayID: String) -> DisplayPreference {
    displayPreferences[displayID] ?? DisplayPreference(isEnabled: false, showsBackground: false)
  }

  func setDisplayEnabled(_ enabled: Bool, displayID: String) {
    var updated = displayPreferences
    var preference = self.preference(for: displayID)
    preference.isEnabled = enabled
    updated[displayID] = preference
    displayPreferences = updated
  }

  func setDisplayBackground(_ enabled: Bool, displayID: String) {
    var updated = displayPreferences
    var preference = self.preference(for: displayID)
    preference.showsBackground = enabled
    updated[displayID] = preference
    displayPreferences = updated
  }

  func resetAppearanceAndFormat() {
    let isClockVisible = preferences.isClockVisible
    let showsMenuBarClock = preferences.showsMenuBarClock
    let windowLayer = preferences.windowLayer
    let launchAtLogin = preferences.launchAtLogin
    preferences = .defaults
    preferences.isClockVisible = isClockVisible
    preferences.showsMenuBarClock = showsMenuBarClock
    preferences.windowLayer = windowLayer
    preferences.launchAtLogin = launchAtLogin
  }

  func setLaunchAtLoginState(_ enabled: Bool) {
    preferences.launchAtLogin = enabled
  }

  private func persistPreferences() {
    guard let data = try? encoder.encode(preferences) else { return }
    defaults.set(data, forKey: Keys.preferences)
  }

  private func persistDisplayPreferences() {
    guard let data = try? encoder.encode(displayPreferences) else { return }
    defaults.set(data, forKey: Keys.displays)
  }
}
