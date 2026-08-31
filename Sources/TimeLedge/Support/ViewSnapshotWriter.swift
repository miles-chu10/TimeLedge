import AppKit

enum ViewSnapshotWriter {
  static func write(view: NSView, to url: URL) throws {
    view.layoutSubtreeIfNeeded()
    let bounds = view.bounds
    guard bounds.width > 0,
      bounds.height > 0,
      let representation = view.bitmapImageRepForCachingDisplay(in: bounds)
    else {
      throw SnapshotError.emptyView
    }

    view.cacheDisplay(in: bounds, to: representation)
    guard let data = representation.representation(using: .png, properties: [:]) else {
      throw SnapshotError.encodingFailed
    }
    try data.write(to: url, options: .atomic)
  }

  enum SnapshotError: Error {
    case emptyView
    case encodingFailed
  }
}
