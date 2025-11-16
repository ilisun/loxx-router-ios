// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LoxxRouter",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "LoxxRouter",
            targets: ["LoxxRouter"]
        ),
    ],
    targets: [
        // ═══════════════════════════════════════════════════
        // Pure Swift API (Bridge is now in XCFramework)
        // ═══════════════════════════════════════════════════
        .target(
            name: "LoxxRouter",
            dependencies: ["LoxxRouterCore"],
            path: "Sources/LoxxRouter",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // ═══════════════════════════════════════════════════
        // C++ Core (Binary Target from loxx-core releases)
        // ═══════════════════════════════════════════════════
        .binaryTarget(
            name: "LoxxRouterCore",
            url: "https://github.com/ilisun/loxx-core/releases/download/v1.0.3/loxx-core.xcframework.zip",
            checksum: "2b2786f5d6a4d8a79bf5d0c7b2b9f9dbdcfc6cbf92e43863011e065f4faa95ec"
        ),
        
        // ═══════════════════════════════════════════════════
        // Tests
        // ═══════════════════════════════════════════════════
        .testTarget(
            name: "LoxxRouterTests",
            dependencies: ["LoxxRouter"],
            path: "Tests/LoxxRouterTests",
            resources: [.copy("Resources")]
        ),
    ]
)
