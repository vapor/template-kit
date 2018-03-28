// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TemplateKit",
    products: [
        .library(name: "TemplateKit", targets: ["TemplateKit"]),
        .library(name: "Mustache", targets: ["Mustache"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc.2"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0-rc.2"),
    ],
    targets: [
        .target(name: "Mustache", dependencies: ["Core", "TemplateKit"]),
        .testTarget(name: "MustacheTests", dependencies: ["Mustache"]),
        .target(name: "TemplateKit", dependencies: ["Async", "Bits", "Core", "Service"]),
        .testTarget(name: "TemplateKitTests", dependencies: ["TemplateKit"]),
    ]
)
