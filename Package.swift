// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SBBJourneyMaps",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SBBJourneyMaps",
            targets: ["SBBJourneyMaps"])
    ],
    dependencies: [
        // To get a new Version of MapLibre: remove comment below and set the new Version. Comment the "old" version from targets. Then see on the Project navigator the Package Dependencies and look at the content of the Package.swift ob the MapLibre package. You can then adapt the .target section and re-comment the line below.
        //                .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMajor(from: "6.4.0"))
        // OR you can go directly to https://github.com/maplibre/maplibre-native/releases and pick the desired version and adapt the .binaryTarget section in the targets below.
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SBBJourneyMaps",
            dependencies: ["MapLibre"],
            resources: [
                .process("Resources")
            ]),
        // Because the direct dependency to the package url does not work, we'll have to add the binaryTarget directly.
        .binaryTarget(
            name: "MapLibre",
            url: "https://github.com/maplibre/maplibre-native/releases/download/ios-v6.20.1/MapLibre.dynamic.xcframework.zip",
            checksum: "d5c3bfbd6b62196f3bb3b31b66570769d4e586170a02e39134bf665538f55d7d"),
        .testTarget(
            name: "SBBJourneyMapsTests",
            dependencies: ["SBBJourneyMaps"]),
    ]
)
