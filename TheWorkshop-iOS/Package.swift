// swift-tools-version:5.9
// TheWorkshop-iOS Package Description

import PackageDescription

let package = Package(
    name: "TheWorkshop",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .app(
            name: "TheWorkshop",
            targets: ["TheWorkshop"]
        )
    ],
    targets: [
        .target(
            name: "TheWorkshop",
            dependencies: [],
            path: ".",
            exclude: [
                "Package.swift",
                "README.md"
            ],
            resources: [],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
