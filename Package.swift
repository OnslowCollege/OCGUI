// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCGUI",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OCGUI",
            targets: ["OCGUI"]),
    ], dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", exact: "0.3.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OCGUI",
            dependencies: ["PythonKit"]
        ),
        .testTarget(
            name: "OCGUITests",
            dependencies: ["OCGUI"]),
    ]
)
