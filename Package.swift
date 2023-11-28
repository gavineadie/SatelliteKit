// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v4)
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
