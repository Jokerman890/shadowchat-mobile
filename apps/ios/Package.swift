// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ShadowChatApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ShadowChatApp", targets: ["ShadowChatApp"])
    ],
    targets: [
        .target(name: "ShadowChatCoreBridge"),
        .target(name: "ShadowChatApp", dependencies: ["ShadowChatCoreBridge"]),
        .testTarget(name: "ShadowChatAppTests", dependencies: ["ShadowChatApp"])
    ]
)
