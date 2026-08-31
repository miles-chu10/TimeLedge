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
    XCTAssertTrue(controller.statusItemHasImage)
    XCTAssertEqual(controller.statusItemLength, NSStatusItem.squareLength)
    controller.stop()
  }

  func testVisibleClockKeepsTheConfiguredAccessibilityTitle() {
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

  func testBlankRenderingCustomClockFallsBackToStandardTime() {
    var preferences = ClockPreferences.defaults
    preferences.customFormatEnabled = true
    preferences.customFormat = "'   '"
    let date = Date(timeIntervalSince1970: 1_000_000)
    var fallbackPreferences = preferences
    fallbackPreferences.customFormatEnabled = false
    fallbackPreferences.showDate = false
    fallbackPreferences.showWeekday = false

    XCTAssertEqual(
      StatusItemController.menuBarTitle(
        at: date,
        preferences: preferences,
        isClockVisible: true
      ),
      ClockFormatter.string(from: date, preferences: fallbackPreferences)
    )
  }

  func testStatusItemUsesTheAppIconWhenTheBundleProvidesOne() {
    let appIcon = NSImage(size: NSSize(width: 512, height: 512), flipped: false) { rect in
      NSColor.systemBlue.setFill()
      rect.fill()
      return true
    }

    let image = StatusItemController.statusItemImage(appIcon: appIcon)

    XCTAssertEqual(image.size, NSSize(width: 18, height: 18))
    XCTAssertFalse(image.isTemplate)
  }

  func testStatusItemFallsBackToATemplateSymbolWithoutAnAppIcon() {
    let image = StatusItemController.statusItemImage(appIcon: nil)

    XCTAssertTrue(image.isTemplate)
  }

  func testStatusItemIgnoresAnInvalidAppIcon() {
    let image = StatusItemController.statusItemImage(appIcon: NSImage())

    XCTAssertTrue(image.isTemplate)
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
