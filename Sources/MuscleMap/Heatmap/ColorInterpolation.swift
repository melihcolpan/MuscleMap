//
//  ColorInterpolation.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Defines how color values are interpolated across a heatmap color scale.
public enum ColorInterpolation: Sendable {
    /// Linear interpolation (default behavior).
    case linear
    /// Slow start, fast end (ease-in curve).
    case easeIn
    /// Fast start, slow end (ease-out curve).
    case easeOut
    /// Slow start and end (ease-in-out curve).
    case easeInOut
    /// Stepped interpolation with discrete levels.
    case step(count: Int)
    /// Custom interpolation curve.
    case custom(@Sendable (Double) -> Double)

    /// Applies the interpolation curve to a fraction value (0.0 - 1.0).
    public func apply(_ t: Double) -> Double {
        let clamped = min(max(t, 0), 1)
        switch self {
        case .linear:
            return clamped
        case .easeIn:
            return clamped * clamped
        case .easeOut:
            return 1.0 - (1.0 - clamped) * (1.0 - clamped)
        case .easeInOut:
            if clamped < 0.5 {
                return 2.0 * clamped * clamped
            } else {
                return 1.0 - pow(-2.0 * clamped + 2.0, 2) / 2.0
            }
        case .step(let count):
            guard count > 0 else { return clamped }
            let stepped = (clamped * Double(count)).rounded(.down) / Double(count)
            return min(stepped, 1.0)
        case .custom(let curve):
            return min(max(curve(clamped), 0), 1)
        }
    }
}

// MARK: - Equatable

extension ColorInterpolation: Equatable {
    public static func == (lhs: ColorInterpolation, rhs: ColorInterpolation) -> Bool {
        switch (lhs, rhs) {
        case (.linear, .linear):
            return true
        case (.easeIn, .easeIn):
            return true
        case (.easeOut, .easeOut):
            return true
        case (.easeInOut, .easeInOut):
            return true
        case (.step(let a), .step(let b)):
            return a == b
        case (.custom, .custom):
            return false
        default:
            return false
        }
    }
}
