// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "smite_url",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
		.package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
		.package(url: "https://github.com/attaswift/BigInt", from: "5.4.1"),
		.package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
		.package(url: "https://github.com/m1thrandir225/base58-swift", from: "1.0.0"),
		.package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
		.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0")

    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
				.product(name: "Fluent", package: "fluent"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
				.product(name: "Redis", package: "redis"),
				.product(name: "BigInt", package: "BigInt"),
				.product(name: "Leaf", package: "leaf"),
				.product(name: "Base58", package: "base58-swift"),
				.product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
