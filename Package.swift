// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "apple-mail-exporter",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "AppleMailExporter", targets: ["AppleMailExporter"]),
        .executable(name: "apple-mail-exporter", targets: ["CLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .systemLibrary(
            name: "CSQLite",
            pkgConfig: nil,
            providers: []
        ),
        .target(
            name: "AppleMailExporter",
            dependencies: ["CSQLite"]
        ),
        .executableTarget(
            name: "CLI",
            dependencies: [
                "AppleMailExporter",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "AppleMailExporterTests",
            dependencies: ["AppleMailExporter"]
        ),
    ]
)
