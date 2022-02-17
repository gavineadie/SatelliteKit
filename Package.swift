// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v10_12), .iOS(.v9),
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
        .testTarget(name: "SatelliteKitTests", dependencies: ["SatelliteKit"]),
    ]
)
