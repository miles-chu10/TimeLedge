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

  func testDesktopMacEnablesEveryExternalDisplayItHas() {
    let store = PreferencesStore(defaults: defaults)
    let first = descriptor(id: "first", builtIn: false)
    let second = descriptor(id: "second", builtIn: false)

    store.synchronize(displays: [first, second])

    XCTAssertTrue(store.preference(for: first.id).isEnabled)
    XCTAssertTrue(store.preference(for: second.id).isEnabled)
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

  func testTopRightPlacementPinsLegacyAuxiliaryAreaToPhysicalTopEdge() {
    let bounds = SystemDisplayProvider.topRightPlacementBounds(
      screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
      safeAreaTop: 32,
      statusBarThickness: 22,
      auxiliaryTopRightArea: CGRect(x: -226, y: 918, width: 663.5, height: 32)
    )

    XCTAssertEqual(bounds, CGRect(x: 848.5, y: 950, width: 663.5, height: 32))
  }

  func testTopRightPlacementUsesRightHalfForNotchedScreenFallback() {
    let bounds = SystemDisplayProvider.topRightPlacementBounds(
      screenFrame: CGRect(x: -1512, y: 100, width: 1512, height: 982),
      safeAreaTop: 32,
      statusBarThickness: 22,
      auxiliaryTopRightArea: nil
    )

    XCTAssertEqual(bounds, CGRect(x: -756, y: 1050, width: 756, height: 32))
  }

  func testTopRightPlacementUsesFullWidthForNonNotchedScreenFallback() {
    let bounds = SystemDisplayProvider.topRightPlacementBounds(
      screenFrame: CGRect(x: 0, y: -1080, width: 1920, height: 1080),
      safeAreaTop: 0,
      statusBarThickness: 24,
      auxiliaryTopRightArea: nil
    )

    XCTAssertEqual(bounds, CGRect(x: 0, y: -24, width: 1920, height: 24))
  }

  func testFullscreenEvidenceDoesNotIgnoreVisibleMenuBarOnNonNotchedDisplay() {
    XCTAssertEqual(
      SystemDisplayProvider.fullscreenTopInset(
        safeAreaTop: 24,
        statusBarThickness: 24
      ),
      0
    )
  }

  func testFullscreenEvidenceAllowsHardwareSafeAreaOnNotchedDisplay() {
    XCTAssertEqual(
      SystemDisplayProvider.fullscreenTopInset(
        safeAreaTop: 32,
        statusBarThickness: 22
      ),
      32
    )
  }

  func testDisplayPlacementAnchorsBelowVisibleSystemTopStrip() {
    XCTAssertEqual(
      notchedDisplay().placementBounds(menuBarIsVisible: true),
      CGRect(x: 848.5, y: 0, width: 663.5, height: 950)
    )
  }

  func testDisplayPlacementTakesOverTheStripWhenTheMenuBarIsHidden() {
    XCTAssertEqual(
      notchedDisplay().placementBounds(menuBarIsVisible: false),
      CGRect(x: 848.5, y: 950, width: 663.5, height: 32)
    )
  }

  func testLegacyPreferencesWithoutNewerKeysKeepEverySavedSetting() throws {
    var saved = ClockPreferences.defaults
    saved.fontSize = 19
    saved.fontFamily = .monospaced
    saved.rightMargin = .wide
    saved.use24HourFormat = true

    var json = try XCTUnwrap(
      JSONSerialization.jsonObject(with: try JSONEncoder().encode(saved)) as? [String: Any]
    )
    json.removeValue(forKey: "showsMenuBarClock")
    defaults.set(
      try JSONSerialization.data(withJSONObject: json),
      forKey: "TimeLedge.preferences.v1"
    )

    let store = PreferencesStore(defaults: defaults)

    XCTAssertEqual(store.preferences.fontSize, 19)
    XCTAssertEqual(store.preferences.fontFamily, .monospaced)
    XCTAssertEqual(store.preferences.rightMargin, .wide)
    XCTAssertTrue(store.preferences.use24HourFormat)
    XCTAssertFalse(store.preferences.showsMenuBarClock)
  }

  func testAppearanceResetKeepsTheMenuBarClockChoice() {
    let store = PreferencesStore(defaults: defaults)
    store.preferences.showsMenuBarClock = true

    store.resetAppearanceAndFormat()

    XCTAssertTrue(store.preferences.showsMenuBarClock)
  }

  private func notchedDisplay() -> DisplayDescriptor {
    DisplayDescriptor(
      id: "built-in",
      localizedName: "Built-in Retina Display",
      displayID: 1,
      isBuiltIn: true,
      frame: CGRect(x: 0, y: 0, width: 1512, height: 982),
      topRightSafeArea: CGRect(x: 848.5, y: 950, width: 663.5, height: 32)
    )
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
