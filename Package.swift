// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v10_12), .iOS(.v9),
    ],
    products: [
        .library(name: "SatelliteKit", targets: ["SatelliteKit"]),
    ],
    targets: [
        .target(name: "SatelliteKit",
                dependencies: [ ],
                linkerSettings: [
                    .unsafeFlags( ["-Xlinker", "-sectcreate",
                                   "-Xlinker", "__TEXT",
                                   "-Xlinker", "__info_plist",
                                   "-Xlinker", "Support/Info.plist"] )
                ]
               ),
        .testTarget(name: "SatelliteKitTests", dependencies: ["SatelliteKit"]),
    ]
)
