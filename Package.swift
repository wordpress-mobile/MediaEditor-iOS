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
        .package(
          url: "https://github.com/mokagio/TOCropViewController",
          revision: "e857007a7d099ef173f8733d7964b7abdff79772"
        )
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
