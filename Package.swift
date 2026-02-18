// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LNSCalendarHeatmap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "LNSCalendarHeatmap",
            targets: ["LNSCalendarHeatmap"]
        ),
    ],
    targets: [
        .target(
            name: "LNSCalendarHeatmap"
        ),
        .testTarget(
            name: "LNSCalendarHeatmapTests",
            dependencies: ["LNSCalendarHeatmap"]
        ),
    ]
)
