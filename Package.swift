// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SatelliteKit",
    platforms: [
        .macOS(.v11), .iOS(.v12), .tvOS(.v12), .watchOS(.v4) // , .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SatelliteKit",
            targets: ["SatelliteKit"]),
    ],
    targets: [
        .target(
            name: "SatelliteKit",
            dependencies: [ ],
            resources: [ .copy("Resourses/Pict.jpg") ],     // .embed
            swiftSettings: [
                .define("ENABLE_SOMETHING"/*, .when(configuration: .release)*/),
            ]
//            linkerSettings: [
//                .unsafeFlags( ["-Xlinker", "-sectcreate",
//                               "-Xlinker", "__TEXT",
//                               "-Xlinker", "__info_plist",
//                               "-Xlinker", "Resources/Info.plist"] )
//            ]
        ),
        .testTarget(name: "SatelliteKitTests", dependencies: ["SatelliteKit"])
    ]
)
