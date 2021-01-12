// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntegirtySwift",
    platforms: [
          // Add support for all platforms starting from a specific version.
          .iOS(.v12),
          .tvOS(.v12),
          .watchOS(.v4),
          .macOS(.v10_14),
      ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "IntegirtySwift",
            targets: ["IntegirtySwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/CodeNationDev/SimplyLogger.git", from: "0.0.6"),
    ],
    targets: [
        .target(
            name: "IntegirtySwift",
            dependencies: [.byName(name: "SimplyLogger")])
    ]
)
