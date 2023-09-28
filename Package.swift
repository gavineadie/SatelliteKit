// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v12), .iOS(.v13), .tvOS(.v14), .watchOS(.v8)
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
