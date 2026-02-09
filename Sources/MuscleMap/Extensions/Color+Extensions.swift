//
//  Color+Extensions.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {

    /// Linearly interpolates between two colors.
    public func interpolate(to other: Color, fraction: Double) -> Color {
        let f = min(max(fraction, 0), 1)

        #if canImport(UIKit)
        let from = UIColor(self)
        let to = UIColor(other)
        #elseif canImport(AppKit)
        let from = NSColor(self)
        let to = NSColor(other)
        #endif

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        #if canImport(UIKit)
        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        #elseif canImport(AppKit)
        let fromRGB = from.usingColorSpace(.deviceRGB) ?? from
        let toRGB = to.usingColorSpace(.deviceRGB) ?? to
        fromRGB.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        toRGB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        #endif

        return Color(
            red: r1 + (r2 - r1) * f,
            green: g1 + (g2 - g1) * f,
            blue: b1 + (b2 - b1) * f,
            opacity: a1 + (a2 - a1) * f
        )
    }

    // MARK: - Cross-Platform System Colors

    public static let mmDefaultFill = Color(white: 0.78)
    public static let mmLightFill = Color(white: 0.85)
    public static let mmLighterFill = Color(white: 0.88)
    public static let mmMediumFill = Color(white: 0.7)
}
