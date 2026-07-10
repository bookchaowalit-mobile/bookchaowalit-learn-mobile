// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Learn",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Learn", targets: ["Learn"])
    ],
    targets: [
        .target(name: "Learn", path: "Sources")
    ]
)
