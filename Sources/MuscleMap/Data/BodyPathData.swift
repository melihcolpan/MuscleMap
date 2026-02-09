//
//  BodyPathData.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// SVG path data for a single body part, supporting common, left, and right sub-paths.
struct BodyPartPathData {
    let slug: BodySlug
    let common: [String]
    let left: [String]
    let right: [String]

    init(slug: BodySlug, common: [String] = [], left: [String] = [], right: [String] = []) {
        self.slug = slug
        self.common = common
        self.left = left
        self.right = right
    }

    /// All SVG path strings combined.
    var allPaths: [String] {
        common + left + right
    }
}

/// ViewBox configuration for body rendering.
struct BodyViewBox {
    let origin: CGPoint
    let size: CGSize

    var rect: CGRect {
        CGRect(origin: origin, size: size)
    }

    static let maleFront = BodyViewBox(
        origin: CGPoint(x: 0, y: 95),
        size: CGSize(width: 727, height: 1280)
    )

    static let maleBack = BodyViewBox(
        origin: CGPoint(x: 860, y: 95),
        size: CGSize(width: 600, height: 1300)
    )

    static let femaleFront = BodyViewBox(
        origin: CGPoint(x: 0, y: 0),
        size: CGSize(width: 650, height: 1450)
    )

    static let femaleBack = BodyViewBox(
        origin: CGPoint(x: 830, y: 0),
        size: CGSize(width: 500, height: 1430)
    )
}

/// Provides body path data for a given gender and side.
struct BodyPathProvider {

    static func paths(gender: BodyGender, side: BodySide) -> [BodyPartPathData] {
        switch (gender, side) {
        case (.male, .front): return MaleFrontPaths.paths
        case (.male, .back): return MaleBackPaths.paths
        case (.female, .front): return FemaleFrontPaths.paths
        case (.female, .back): return FemaleBackPaths.paths
        }
    }

    static func viewBox(gender: BodyGender, side: BodySide) -> BodyViewBox {
        switch (gender, side) {
        case (.male, .front): return .maleFront
        case (.male, .back): return .maleBack
        case (.female, .front): return .femaleFront
        case (.female, .back): return .femaleBack
        }
    }
}
