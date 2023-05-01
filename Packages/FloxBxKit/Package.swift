// swift-tools-version:5.6
// swiftlint:disable explicit_top_level_acl explicit_acl

import PackageDescription

let package = Package(
  name: "FloxBx",
  platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8)],
  products: [
    .library(
      name: "FloxBxUI",
      targets: ["FloxBxUI"]
    ),
    .library(
      name: "FloxBxServerKit",
      targets: ["FloxBxServerKit"]
    ),
    .executable(name: "fbd", targets: ["fbd"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/Sublimation.git", from: "0.1.3"),
    .package(url: "https://github.com/vapor/apns.git", from: "4.0.0-beta.2"),
    .package(path: "Packages/StealthyStash"),
    .package(path: "Packages/Prch")
  ],
  targets: [
    .target(name: "FelinePine"),
    .target(name: "FloxBxUtilities"),
    // .target(name: "FloxBxModeling"),
    .target(name: "FloxBxModels", dependencies: ["FloxBxUtilities", .product(name: "PrchModel", package: "Prch")]),
    .target(name: "FloxBxLogging", dependencies: ["FelinePine"]),
    // .target(name: "FloxBxNetworking", dependencies: ["FloxBxLogging"]),
    .target(name: "FloxBxGroupActivities", dependencies: ["FloxBxLogging"]),
    .target(name: "FloxBxAuth", dependencies: ["FloxBxLogging", "StealthyStash"]),
    .target(
      name: "RouteGroups",
      dependencies: [.product(name: "Vapor", package: "vapor")]
    ),
    .executableTarget(
      name: "fbd",
      dependencies: ["FloxBxServerKit"]
    ),
    .target(
      name: "FloxBxRequests",
      dependencies: ["FloxBxModels", .product(name: "PrchModel", package: "Prch")]
    ),
    .target(
      name: "FloxBxDatabase",
      dependencies: ["FloxBxUtilities", .product(name: "Fluent", package: "fluent")]
    ),
    .target(name: "FloxBxUI", dependencies: [
      .product(name: "Sublimation", package: "Sublimation"),
      "FloxBxRequests",
      "FloxBxUtilities",
      "FloxBxAuth",
      "FloxBxGroupActivities",
      .product(name: "Prch", package: "Prch")
    ]),
    .target(
      name: "FloxBxServerKit",
      dependencies: [
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "SublimationVapor", package: "Sublimation"),
        .product(name: "APNS", package: "apns"),
        "FloxBxModels", "FloxBxDatabase", "RouteGroups", "FloxBxLogging"
      ],
      swiftSettings: [
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
      ]
    ),
    .testTarget(
      name: "FloxBxServerKitTests",
      dependencies: [
        "FloxBxServerKit",
        .product(name: "XCTVapor", package: "vapor")
      ]
    )
  ]
)
