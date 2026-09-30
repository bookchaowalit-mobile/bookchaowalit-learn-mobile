// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Learn",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LearnCore", targets: ["LearnCore"]),
        .library(name: "LearnUI", targets: ["LearnUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "LearnCore", path: "Sources/LearnCore"),
        .target(name: "LearnUI", dependencies: ["LearnCore"], path: "Sources/LearnUI"),
        .testTarget(name: "LearnCoreTests", dependencies: ["LearnCore"], path: "Tests/LearnCoreTests"),
    ]
)
