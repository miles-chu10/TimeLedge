import Foundation

public struct WindowIdentity: Hashable, Sendable {
  public let ownerProcessIdentifier: Int32
  public let windowNumber: UInt32

  public init(ownerProcessIdentifier: Int32, windowNumber: UInt32) {
    self.ownerProcessIdentifier = ownerProcessIdentifier
    self.windowNumber = windowNumber
  }
}

public struct WindowCoverageSnapshot: Equatable, Sendable {
  public let identity: WindowIdentity
  public let coveredDisplayIDs: Set<String>

  public init(identity: WindowIdentity, coveredDisplayIDs: Set<String>) {
    self.identity = identity
    self.coveredDisplayIDs = coveredDisplayIDs
  }
}

public struct FullscreenTransitionDetector: Sendable {
  private var lastNoncoveringObservation: [WindowIdentity: TimeInterval] = [:]
  private var verifiedFullscreenWindows: Set<WindowIdentity> = []
  private var transitionStartedAt: TimeInterval?
  private var transitionDeadline: TimeInterval?

  public init() {}

  public mutating func noteSpaceChange(
    at time: TimeInterval,
    transitionWindow: TimeInterval = 5
  ) {
    transitionStartedAt = time
    transitionDeadline = time + max(0, transitionWindow)
  }

  public mutating func update(
    snapshots: [WindowCoverageSnapshot],
    at time: TimeInterval,
    lookback: TimeInterval = 5
  ) -> Set<String> {
    if let deadline = transitionDeadline, time > deadline {
      transitionStartedAt = nil
      transitionDeadline = nil
    }

    var coveredDisplayIDs: Set<String> = []
    var didVerifyTransition = false
    for snapshot in snapshots {
      if snapshot.coveredDisplayIDs.isEmpty {
        lastNoncoveringObservation[snapshot.identity] = time
        verifiedFullscreenWindows.remove(snapshot.identity)
        continue
      }

      if !verifiedFullscreenWindows.contains(snapshot.identity),
        let transitionStartedAt,
        let transitionDeadline,
        time <= transitionDeadline,
        let lastNoncovering = lastNoncoveringObservation[snapshot.identity],
        lastNoncovering >= transitionStartedAt - max(0, lookback)
      {
        verifiedFullscreenWindows.insert(snapshot.identity)
        didVerifyTransition = true
      }

      if verifiedFullscreenWindows.contains(snapshot.identity) {
        coveredDisplayIDs.formUnion(snapshot.coveredDisplayIDs)
      }
    }
    if didVerifyTransition {
      transitionStartedAt = nil
      transitionDeadline = nil
    }
    return coveredDisplayIDs
  }
}
