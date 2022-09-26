// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FontFileReader",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FontFileReader",
            targets: ["FontFileReader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/karlvr/Brotli", branch: "master"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
                .upToNextMajor(from: "1.0.3") // or `.upToNextMinor
        )
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FontFileReader",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Brotli", package:"Brotli")
            ]),
        .testTarget(
            name: "FontFileReaderTests",
            dependencies: ["FontFileReader"]),
    ]
)
