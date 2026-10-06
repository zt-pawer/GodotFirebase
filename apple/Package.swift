// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-Xfrontend", "-internalize-at-link",
        "-Xfrontend", "-lto=llvm-full",
        "-Xfrontend", "-conditional-runtime-records"
    ])
]

let linkerSettings: [LinkerSetting] = [
    .unsafeFlags(["-Xlinker", "-dead_strip"])
]

let runtimeDependency: Target.Dependency = .product(
    name: "SwiftGodotRuntime",
    package: "SwiftGodotBinary"
)

let package = Package(
    name: "GodotFirebase",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "GodotFirebase", type: .dynamic, targets: ["GodotFirebase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodotBinary", revision: "bf7cd9cb51b30039199c47811c486976923af93e"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "GodotFirebase",
            dependencies: [
                runtimeDependency,
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
            ],
            path: "Sources/GodotFirebase",
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        ),
        .testTarget(
            name: "GodotFirebaseTests",
            dependencies: ["GodotFirebase"]
        ),
    ]
)
