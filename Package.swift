// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SharingFirebase",
  platforms: [
    .macOS(.v15),
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "SharingRemoteConfig",
      targets: ["SharingRemoteConfig"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/zunda-pixel/firebase-swift", from: "1.0.5"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.4.0"),
  ],
  targets: [
    .target(
      name: "SharingRemoteConfig",
      dependencies: [
        .product(name: "RemoteConfig", package: "firebase-swift"),
        .product(name: "Sharing", package: "swift-sharing"),
      ]
    ),
  ]
)
