// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FloxBx",
  platforms: [.macOS(.v11), .iOS(.v14), .watchOS(.v7)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
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
    .package(url: "https://github.com/brightdigit/Canary.git", from: "0.2.0-beta.1")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .executableTarget(
      name: "fbd",
      dependencies: ["FloxBxServerKit"]
    ),
    .target(name: "FloxBxModels",
            dependencies: ["FloxBxNetworking"]),
    .target(name: "FloxBxNetworking", dependencies: ["FloxBxAuth"]),
    .target(name: "FloxBxUI", dependencies: [
      "Canary",
      "FloxBxModels",
      "FloxBxAuth",
      "FloxBxGroupActivities"
    ]),
    .target(name: "FloxBxGroupActivities"),
    .target(name: "FloxBxAuth"),
    .target(
      name: "FloxBxServerKit",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        .product(name: "Vapor", package: "vapor"),
        "FloxBxModels",
        "Canary"
      ],
      swiftSettings: [
        // Enable better optimizations when building in Release configuration. Despite the use of
        // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
        // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
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