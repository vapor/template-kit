// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "TemplateKit",
    products: [
        .library(name: "TemplateKit", targets: ["TemplateKit"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "TemplateKit", dependencies: ["Async", "Bits", "Core", "Service"]),
        .testTarget(name: "TemplateKitTests", dependencies: ["TemplateKit"]),
    ]
)
