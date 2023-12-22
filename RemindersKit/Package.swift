// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemindersKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Domain",
                 targets: ["Domain"]),
        .library(name: "AppFeature",
                 targets: ["AppFeature"]),
        .library(name: "RemindersList",
                 targets: ["RemindersList"]),
        .library(name: "ReminderForm",
                 targets: ["ReminderForm"]),
        .library(name: "ReminderDetail",
                 targets: ["ReminderDetail"]),

    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "observation-beta")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Domain"),
        .target(name: "AppFeature", dependencies: [
            "RemindersList",
            "ReminderDetail",
            "ReminderForm",
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "RemindersList", dependencies: [
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "ReminderForm", dependencies: [
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "ReminderDetail", dependencies: [
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .testTarget(name: "ReminderFormTests", dependencies: [
            "Domain",
            "ReminderForm",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .testTarget(name: "ReminderListTests", dependencies: [
            "Domain",
            "RemindersList",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ])
    ]
)
