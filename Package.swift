// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v11), .iOS(.v18), .tvOS(.v12), .watchOS(.v10), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SatelliteKit",
            targets: ["SatelliteKit"]),
    ],
    targets: [
        .target(
            name: "SatelliteKit",
            dependencies: [ ]
        ),
        .testTarget(name: "SatelliteKitTests", dependencies: ["SatelliteKit"])
    ]
)
