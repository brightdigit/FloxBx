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
   .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"]),
]

let package = Package(
    name: "RouteGroups",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RouteGroups",
            targets: ["RouteGroups"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RouteGroups",
             swiftSettings: swiftSettings),
        .testTarget(
            name: "RouteGroupsTests",
            dependencies: ["RouteGroups"]),
    ]
)
