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

  func testAccessibilityTimeRefreshesWithoutOpeningMenu() {
    let button = NSButton()
    var date = Date(timeIntervalSince1970: 1_000_000)
    var preferences = ClockPreferences.defaults
    preferences.showSeconds = true
    let timer = StatusItemController.scheduleAccessibilityUpdates(
      button: button, now: { date }, preferences: { preferences }
    )
    defer { timer.invalidate() }
    timer.fire()
    let initialLabel = button.accessibilityLabel()
    date.addTimeInterval(65)
    // Exercise the registered run-loop timer, with no menu/controller refresh.
    let deadline = Date().addingTimeInterval(2)
    while button.accessibilityLabel() == initialLabel && Date() < deadline {
      RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
    XCTAssertNotEqual(button.accessibilityLabel(), initialLabel)
    XCTAssertEqual(
      button.accessibilityLabel(),
      "TimeLedge \(ClockFormatter.string(from: date, preferences: preferences))"
    )
    preferences.isClockVisible = false
    timer.fire()
    XCTAssertEqual(button.accessibilityLabel(), "TimeLedge")
    timer.invalidate()
    date.addTimeInterval(65)
    preferences.isClockVisible = true
    timer.fire()
    XCTAssertEqual(button.accessibilityLabel(), "TimeLedge")
  }

  func testAccessibilityTimerDoesNotRetainItsButton() {
    weak var weakButton: NSButton?
    let timer = autoreleasepool {
      let button = NSButton()
      weakButton = button
      return StatusItemController.scheduleAccessibilityUpdates(button: button) { .defaults }
    }
    XCTAssertNil(weakButton)
    timer.fire()
    XCTAssertFalse(timer.isValid)
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
