import AppKit
import Combine
import XCTest

@testable import TimeLedge

@MainActor
final class OverlayCoordinatorTests: XCTestCase {
  func testSpaceChangeRefreshesLearnedDisplayGeometry() async {
    let suite = "TimeLedgeTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let store = PreferencesStore(defaults: defaults)
    store.preferences.isClockVisible = false
    let provider = MutableDisplayProvider()
    provider.bandHeight = 22
    let coordinator = OverlayCoordinator(store: store, displayProvider: provider)
    coordinator.start()
    defer { coordinator.stop() }
    XCTAssertEqual(store.displays.first?.topRightSafeArea?.height, 22)

    let refreshed = expectation(description: "learned band reaches stored display")
    let observation = store.$displays.sink { displays in
      if displays.first?.topRightSafeArea?.height == 30 {
        refreshed.fulfill()
      }
    }
    defer { observation.cancel() }
    provider.bandHeight = 30
    NSWorkspace.shared.notificationCenter.post(
      name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
    await fulfillment(of: [refreshed], timeout: 2)
  }
}

@MainActor
private final class MutableDisplayProvider: DisplayProviding {
  var bandHeight: CGFloat = 22

  func currentDisplays() -> [DisplayDescriptor] {
    [
      DisplayDescriptor(
        id: "fixture", localizedName: "Fixture", displayID: 1, isBuiltIn: false,
        frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
        topRightSafeArea: CGRect(x: 0, y: 900 - bandHeight, width: 1440, height: bandHeight)
      )
    ]
  }
}
