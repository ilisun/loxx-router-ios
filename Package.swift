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
        // Public Swift API
        // ═══════════════════════════════════════════════════
        .target(
            name: "LoxxRouter",
            dependencies: ["LoxxRouterBridge"],
            path: "Sources/LoxxRouter",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // ═══════════════════════════════════════════════════
        // Private Objective-C++ Bridge
        // ═══════════════════════════════════════════════════
        .target(
            name: "LoxxRouterBridge",
            dependencies: ["LoxxRouterCore"],
            path: "Sources/LoxxRouterBridge",
            publicHeadersPath: "include"
        ),
        
        // ═══════════════════════════════════════════════════
        // C++ Core (Binary Target from loxx-core releases)
        // ═══════════════════════════════════════════════════
        .binaryTarget(
            name: "LoxxRouterCore",
            url: "https://github.com/ilisun/loxx-core/releases/download/v1.0.1/loxx-core.xcframework.zip",
            checksum: "f48a716ab9435b33861294c403a2c342f172cb0ccd3b007bb4bbc13b12e12a3e"
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
