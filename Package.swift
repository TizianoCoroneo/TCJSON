// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCJSON",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TCJSON",
            targets: ["TCJSON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.6.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "10.0.1"),
    ],
    targets: [
        .target(
            name: "TCJSON",
            dependencies: ["Alamofire", "Moya"]),
    ]
)
