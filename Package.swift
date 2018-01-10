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
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Mustache", dependencies: ["TemplateKit"]),
        .testTarget(name: "MustacheTests", dependencies: ["Mustache"]),
        .target(name: "TemplateKit", dependencies: ["Async", "Bits", "CodableKit"]),
        .testTarget(name: "TemplateKitTests", dependencies: ["TemplateKit"]),
    ]
)
