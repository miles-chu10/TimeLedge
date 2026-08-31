import AppKit
import SwiftUI
import TimeLedgeCore

extension ClockFontFamily {
  var design: Font.Design {
    switch self {
    case .system: return .default
    case .rounded: return .rounded
    case .monospaced: return .monospaced
    }
  }
}

extension ClockFontWeight {
  var swiftUIWeight: Font.Weight {
    switch self {
    case .regular: return .regular
    case .medium: return .medium
    case .semibold: return .semibold
    case .bold: return .bold
    }
  }
}

extension ClockTextColor {
  var color: Color {
    switch self {
    case .adaptive: return .primary
    case .white: return .white
    case .black: return .black
    }
  }
}

extension ClockWindowLayer {
  var windowLevel: NSWindow.Level {
    switch self {
    case .overApps: return .floating
    case .behindApps: return .normal
    }
  }
}
