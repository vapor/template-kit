// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "template-kit",
    products: [
        .library(name: "TemplateKit", targets: ["TemplateKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.10.0")
    ],
    targets: [
        .target(name: "TemplateKit", dependencies: ["NIO"]),
        .testTarget(name: "TemplateKitTests", dependencies: ["TemplateKit"]),
    ]
)
