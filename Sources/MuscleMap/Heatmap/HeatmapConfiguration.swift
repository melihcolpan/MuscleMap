//
//  HeatmapConfiguration.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Configuration for heatmap rendering behavior.
public struct HeatmapConfiguration: Sendable, Equatable {

    /// The color scale used to map intensity values to colors.
    public var colorScale: HeatmapColorScale

    /// The interpolation curve for the color scale.
    public var interpolation: ColorInterpolation

    /// Minimum intensity threshold. Muscles below this value are not highlighted.
    /// Set to `nil` to show all muscles (default).
    public var threshold: Double?

    /// Whether to fill muscles with an intra-muscle gradient based on intensity.
    public var isGradientFillEnabled: Bool

    /// The direction of the intra-muscle gradient.
    public var gradientDirection: GradientDirection

    /// Factor for the low end of the intra-muscle gradient (0.0 - 1.0).
    /// For example, 0.3 means the low color is at 30% of the muscle's intensity.
    public var gradientLowIntensityFactor: Double

    public init(
        colorScale: HeatmapColorScale = .workout,
        interpolation: ColorInterpolation = .linear,
        threshold: Double? = nil,
        isGradientFillEnabled: Bool = false,
        gradientDirection: GradientDirection = .topToBottom,
        gradientLowIntensityFactor: Double = 0.3
    ) {
        self.colorScale = colorScale
        self.interpolation = interpolation
        self.threshold = threshold
        self.isGradientFillEnabled = isGradientFillEnabled
        self.gradientDirection = gradientDirection
        self.gradientLowIntensityFactor = gradientLowIntensityFactor
    }

    /// Default configuration: workout scale, linear interpolation, no threshold, no gradient fill.
    public static let `default` = HeatmapConfiguration()

    // MARK: - Equatable

    public static func == (lhs: HeatmapConfiguration, rhs: HeatmapConfiguration) -> Bool {
        lhs.colorScale.colors == rhs.colorScale.colors &&
        lhs.colorScale.interpolation == rhs.colorScale.interpolation &&
        lhs.interpolation == rhs.interpolation &&
        lhs.threshold == rhs.threshold &&
        lhs.isGradientFillEnabled == rhs.isGradientFillEnabled &&
        lhs.gradientDirection == rhs.gradientDirection &&
        lhs.gradientLowIntensityFactor == rhs.gradientLowIntensityFactor
    }
}

/// The direction of an intra-muscle gradient fill.
public enum GradientDirection: Sendable, Equatable {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft

    /// Converts to SwiftUI start/end unit points.
    var startPoint: UnitPoint {
        switch self {
        case .topToBottom: return .top
        case .bottomToTop: return .bottom
        case .leftToRight: return .leading
        case .rightToLeft: return .trailing
        }
    }

    var endPoint: UnitPoint {
        switch self {
        case .topToBottom: return .bottom
        case .bottomToTop: return .top
        case .leftToRight: return .trailing
        case .rightToLeft: return .leading
        }
    }
}
