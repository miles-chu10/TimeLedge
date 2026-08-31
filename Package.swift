// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "TimeLedge",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "TimeLedgeCore", targets: ["TimeLedgeCore"]),
    .executable(name: "TimeLedge", targets: ["TimeLedge"]),
  ],
  targets: [
    .target(
      name: "TimeLedgeCore",
      path: "Sources/TimeLedgeCore"
    ),
    .executableTarget(
      name: "TimeLedge",
      dependencies: ["TimeLedgeCore"],
      path: "Sources/TimeLedge"
    ),
    .testTarget(
      name: "TimeLedgeCoreTests",
      dependencies: ["TimeLedgeCore"],
      path: "Tests/TimeLedgeCoreTests"
    ),
    .testTarget(
      name: "TimeLedgeAppTests",
      dependencies: ["TimeLedge"],
      path: "Tests/TimeLedgeAppTests"
    ),
  ],
  swiftLanguageVersions: [.v5]
)
