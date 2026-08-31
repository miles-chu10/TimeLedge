import AppKit

final class OverlayPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  private var requestedOverlayFrame: NSRect?

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    requestedOverlayFrame ?? frameRect
  }

  func setOverlayFrame(_ frame: NSRect, display: Bool) {
    requestedOverlayFrame = frame
    setFrame(frame, display: display)
  }

  init() {
    super.init(
      contentRect: CGRect(x: 0, y: 0, width: 160, height: 28),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    isOpaque = false
    backgroundColor = .clear
    hasShadow = false
    ignoresMouseEvents = true
    hidesOnDeactivate = false
    isReleasedWhenClosed = false
    animationBehavior = .none
    collectionBehavior = [
      .canJoinAllSpaces,
      .canJoinAllApplications,
      .fullScreenAuxiliary,
      .stationary,
      .ignoresCycle,
    ]
  }
}
