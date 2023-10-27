// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ipbswiftui_v7",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ipbswiftui_v7",
            targets: ["ipbswiftui_v7"]),
    ],
    dependencies: [
         .package(url: "https://artvs18@bitbucket.org/iHomosum/ipbswiftapi_v7.git", from: "1.0.0"),
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "ipbswiftui_v7",
            dependencies: ["ipbswiftapi_v7", "Kingfisher"]),
        .testTarget(
            name: "ipbswiftui_v7Tests",
            dependencies: ["ipbswiftui_v7"]),
    ]
)
