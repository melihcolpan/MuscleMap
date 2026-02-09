//
//  MuscleFill.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Describes how a muscle region should be filled.
public enum MuscleFill: Sendable, Equatable {
    /// A solid color fill.
    case color(Color)
    /// A linear gradient fill.
    case linearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
    /// A radial gradient fill.
    case radialGradient(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)

    /// Converts the fill description into a `GraphicsContext.Shading` for Canvas rendering.
    public func shading(in rect: CGRect) -> GraphicsContext.Shading {
        switch self {
        case .color(let color):
            return .color(color)
        case .linearGradient(let colors, let startPoint, let endPoint):
            let start = CGPoint(
                x: rect.origin.x + rect.width * startPoint.x,
                y: rect.origin.y + rect.height * startPoint.y
            )
            let end = CGPoint(
                x: rect.origin.x + rect.width * endPoint.x,
                y: rect.origin.y + rect.height * endPoint.y
            )
            return .linearGradient(
                Gradient(colors: colors),
                startPoint: start,
                endPoint: end
            )
        case .radialGradient(let colors, let center, let startRadius, let endRadius):
            let centerPoint = CGPoint(
                x: rect.origin.x + rect.width * center.x,
                y: rect.origin.y + rect.height * center.y
            )
            return .radialGradient(
                Gradient(colors: colors),
                center: centerPoint,
                startRadius: startRadius,
                endRadius: endRadius
            )
        }
    }
}
