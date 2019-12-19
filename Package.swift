// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    products: [
        .library(name: "SatelliteKit", targets: ["SatelliteKit"]),
    ],
    targets: [
        .target(name: "SatelliteKit", dependencies: []),
        .testTarget(name: "SatelliteKitTests", dependencies: ["SatelliteKit"]),
    ]
)
