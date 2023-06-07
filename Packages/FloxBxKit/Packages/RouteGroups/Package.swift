// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("BareSlashRegexLiterals"),
  .enableUpcomingFeature("ConciseMagicFile"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("ForwardTrailingClosures"),
  .enableUpcomingFeature("ImplicitOpenExistentials"),
  .enableUpcomingFeature("StrictConcurrency"),
  .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
  name: "RouteGroups",
  platforms: [.macOS(.v10_15)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "RouteGroups",
      targets: ["RouteGroups"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "RouteGroups",
      dependencies: [.product(name: "Vapor", package: "vapor")],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "RouteGroupsTests",
      dependencies: ["RouteGroups"]
    )
  ]
)
