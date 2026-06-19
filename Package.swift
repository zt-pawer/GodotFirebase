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
    package: "SwiftGodot"
)

let package = Package(
    name: "GodotFirebase",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "GodotFirebase", type: .dynamic, targets: ["GodotFirebase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "f528ba67accbe3cca06c1d401c8f9d7c17022f63"),
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
