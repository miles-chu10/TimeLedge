import AppKit
import SwiftUI
import XCTest

@testable import TimeLedge
@testable import TimeLedgeCore

@MainActor
final class ClockPlacementLayoutTests: XCTestCase {
  func testMaximumFontWithBackgroundStaysBelowScreenTop() {
    let suite = "TimeLedgeTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let store = PreferencesStore(defaults: defaults)
    store.preferences.fontSize = 28
    store.setDisplayBackground(true, displayID: "fixture")

    for family in ClockFontFamily.allCases {
      store.preferences.fontFamily = family
      let view = NSHostingView(
        rootView: ClockView(
          store: store, displayID: "fixture", maximumWidth: 600, onSizeChange: { _ in }
        ))
      view.layoutSubtreeIfNeeded()
      let size = view.fittingSize
      // Current native measurement is 41 points; keep the test layout-driven
      // so future font metrics still exercise the actual supported content.
      XCTAssertGreaterThan(size.height, 32)
      for top: CGFloat in [982, 2062, -98.25] {
        for bandHeight: CGFloat in [22, 24, 32] {
          let screen = CGRect(x: -1920, y: top - 1080, width: 1920, height: 1080)
          let band = OverlayPlacement.menuBarBand(screenFrame: screen, bandHeight: bandHeight)
          let frame = OverlayPlacement.frame(
            in: band, contentSize: size, rightMargin: 12, alignment: .centered)
          XCTAssertEqual(frame.height, size.height.rounded(.up))
          XCTAssertLessThanOrEqual(frame.maxY, screen.maxY)
          XCTAssertLessThan(frame.minY, band.minY)
        }
      }
    }
  }
}
