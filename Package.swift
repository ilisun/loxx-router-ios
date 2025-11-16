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
        // LoxxRouter (Swift API + Obj-C++ Bridge)
        // ═══════════════════════════════════════════════════
        .target(
            name: "LoxxRouter",
            dependencies: ["LoxxRouterCore"],
            path: "Sources",
            sources: [
                "LoxxRouter/",
                "LoxxRouterBridge/LoxxRouterBridge.mm"
            ],
            publicHeadersPath: "LoxxRouterBridge/include",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // ═══════════════════════════════════════════════════
        // C++ Core (Binary Target from loxx-core releases)
        // ═══════════════════════════════════════════════════
        .binaryTarget(
            name: "LoxxRouterCore",
            url: "https://github.com/ilisun/loxx-core/releases/download/v1.0.2/loxx-core.xcframework.zip",
            checksum: "ee837163f0f710d78f849716ecf2c3696a3a1166f4b70b55c070095bb7e50376"
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
