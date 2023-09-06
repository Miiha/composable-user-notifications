// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "composable-user-notifications",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableUserNotifications",
      targets: ["ComposableUserNotifications"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.6.0"),
  ],
  targets: [
    .target(
      name: "ComposableUserNotifications",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .testTarget(
      name: "ComposableUserNotificationsTests",
      dependencies: ["ComposableUserNotifications"]),
  ]
)
