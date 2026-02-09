// swift-tools-version: 5.9

//
//  Package.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import PackageDescription

let package = Package(
    name: "MuscleMap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MuscleMap",
            targets: ["MuscleMap"]
        ),
    ],
    targets: [
        .target(
            name: "MuscleMap",
            path: "Sources/MuscleMap"
        ),
        .testTarget(
            name: "MuscleMapTests",
            dependencies: ["MuscleMap"],
            path: "Tests/MuscleMapTests"
        ),
    ]
)
