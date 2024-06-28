// swift-tools-version:5.10

import Foundation
import PackageDescription

let package = Package(
    name: "MediaEditor",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MediaEditor", targets: ["MediaEditor"])
    ],
    dependencies: [
        .package(url: "https://github.com/TimOliver/TOCropViewController", from: "2.5.3")
    ],
    targets: [
        .target(
            name: "MediaEditor",
            dependencies: [
                .product(name: "CropViewController", package: "TOCropViewController")
            ],
            resources: [.process("Resources")])
    ]
)
