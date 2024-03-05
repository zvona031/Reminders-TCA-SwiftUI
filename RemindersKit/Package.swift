// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemindersKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "RemindersList", targets: ["RemindersList"]),
        .library(name: "ReminderForm", targets: ["ReminderForm"]),
        .library(name: "ReminderDetail", targets: ["ReminderDetail"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.8.0")
    ],
    targets: [
        .target(name: "SwiftUIHelpers"),
        .target(name: "Domain",
                dependencies: [
                    // NOTE: add just Dependencies dependency
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
                ]
               ),
        .target(name: "AppFeature", dependencies: [
            "RemindersList",
            "ReminderDetail",
            "ReminderForm",
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .target(name: "RemindersList", dependencies: [
            "Domain",
            "SwiftUIHelpers",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .target(name: "ReminderForm",
                dependencies: [
                    "Domain",
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
                ],
                resources: [
                    .process("Resources")
                ]),
        .target(name: "ReminderDetail", dependencies: [
            "Domain",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .testTarget(name: "ReminderFormTests", dependencies: [
            "Domain",
            "ReminderForm",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .testTarget(name: "ReminderListTests", dependencies: [
            "Domain",
            "RemindersList",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .testTarget(name: "ReminderDetailTests", dependencies: [
            "Domain",
            "ReminderDetail",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .testTarget(name: "AppFeatureTests", dependencies: [
            "Domain",
            "RemindersList",
            "ReminderDetail",
            "ReminderForm",
            "AppFeature",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ])
    ]
)
