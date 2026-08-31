import XCTest

@testable import TimeLedge
@testable import TimeLedgeCore

@MainActor
final class PreferencesStoreTests: XCTestCase {
  private var suiteName: String!
  private var defaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suiteName = "TimeLedgeTests.\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    defaults = nil
    suiteName = nil
    super.tearDown()
  }

  func testFirstSyncEnablesBuiltInDisplayOnly() {
    let store = PreferencesStore(defaults: defaults)
    let builtIn = descriptor(id: "built-in", builtIn: true)
    let external = descriptor(id: "external", builtIn: false)

    store.synchronize(displays: [builtIn, external])

    XCTAssertTrue(store.preference(for: builtIn.id).isEnabled)
    XCTAssertFalse(store.preference(for: external.id).isEnabled)
  }

  func testDesktopMacFallsBackToFirstDisplay() {
    let store = PreferencesStore(defaults: defaults)
    let first = descriptor(id: "first", builtIn: false)
    let second = descriptor(id: "second", builtIn: false)

    store.synchronize(displays: [first, second])

    XCTAssertTrue(store.preference(for: first.id).isEnabled)
    XCTAssertFalse(store.preference(for: second.id).isEnabled)
  }

  func testPreferencesPersistAcrossStoreInstances() {
    let firstStore = PreferencesStore(defaults: defaults)
    firstStore.preferences.fontSize = 21
    firstStore.preferences.showSeconds = true
    firstStore.visibilityMode = .fullscreenOnly

    let secondStore = PreferencesStore(defaults: defaults)
    XCTAssertEqual(secondStore.preferences.fontSize, 21)
    XCTAssertTrue(secondStore.preferences.showSeconds)
    XCTAssertEqual(secondStore.visibilityMode, .fullscreenOnly)
  }

  func testVisibilityModeDefaultsToAutomatic() {
    XCTAssertEqual(PreferencesStore(defaults: defaults).visibilityMode, .automatic)
  }

  func testAppearanceResetPreservesGeneralSettings() {
    let store = PreferencesStore(defaults: defaults)
    store.preferences.isClockVisible = false
    store.preferences.windowLayer = .behindApps
    store.preferences.launchAtLogin = true
    store.preferences.fontSize = 22

    store.resetAppearanceAndFormat()

    XCTAssertFalse(store.preferences.isClockVisible)
    XCTAssertEqual(store.preferences.windowLayer, .behindApps)
    XCTAssertTrue(store.preferences.launchAtLogin)
    XCTAssertEqual(store.preferences.fontSize, ClockPreferences.defaults.fontSize)
  }

  func testDisplayChoicePersistsAcrossReconnect() {
    let firstStore = PreferencesStore(defaults: defaults)
    let display = descriptor(id: "external", builtIn: false)
    firstStore.synchronize(displays: [display])
    firstStore.setDisplayBackground(true, displayID: display.id)

    let secondStore = PreferencesStore(defaults: defaults)
    secondStore.synchronize(displays: [display])
    XCTAssertTrue(secondStore.preference(for: display.id).showsBackground)
  }

  private func descriptor(id: String, builtIn: Bool) -> DisplayDescriptor {
    DisplayDescriptor(
      id: id,
      localizedName: id,
      displayID: builtIn ? 1 : 2,
      isBuiltIn: builtIn,
      frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
      topRightSafeArea: nil
    )
  }
}
