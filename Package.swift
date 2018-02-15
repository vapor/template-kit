// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TemplateKit",
    products: [
        .library(name: "TemplateKit", targets: ["TemplateKit"]),
        .library(name: "Mustache", targets: ["Mustache"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", "3.0.0-beta.1"..<"3.0.0-beta.2"),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "Mustache", dependencies: ["TemplateKit"]),
        .testTarget(name: "MustacheTests", dependencies: ["Mustache"]),
        .target(name: "TemplateKit", dependencies: ["Async", "Bits", "CodableKit", "Service"]),
        .testTarget(name: "TemplateKitTests", dependencies: ["TemplateKit"]),
    ]
)
