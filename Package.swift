// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TimeZones",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TimeZones",
            path: "Sources/TimeZones"
        )
    ]
)
