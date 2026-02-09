//
//  HeatmapColorScale.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Predefined color scales for heatmap visualization.
public struct HeatmapColorScale: Sendable {

    /// The list of colors from low to high intensity.
    public let colors: [Color]

    /// The interpolation curve applied to intensity values before color mapping.
    public var interpolation: ColorInterpolation

    public init(colors: [Color], interpolation: ColorInterpolation = .linear) {
        self.colors = colors
        self.interpolation = interpolation
    }

    /// Interpolates a color based on an intensity value (0.0 - 1.0).
    public func color(for intensity: Double) -> Color {
        guard !colors.isEmpty else { return .gray }
        guard colors.count > 1 else { return colors[0] }

        let curved = interpolation.apply(min(max(intensity, 0), 1))
        let scaledIndex = curved * Double(colors.count - 1)
        let lowerIndex = Int(scaledIndex)
        let upperIndex = min(lowerIndex + 1, colors.count - 1)
        let fraction = scaledIndex - Double(lowerIndex)

        if fraction < 0.01 {
            return colors[lowerIndex]
        }
        return colors[lowerIndex].interpolate(to: colors[upperIndex], fraction: fraction)
    }
}

// MARK: - Preset Color Scales

extension HeatmapColorScale {

    /// Default workout intensity: gray -> yellow -> orange -> red.
    public static let workout = HeatmapColorScale(colors: [
        .mmDefaultFill,
        .yellow,
        .orange,
        .red
    ])

    /// Cool to warm: blue -> green -> yellow -> red.
    public static let thermal = HeatmapColorScale(colors: [
        .blue,
        .green,
        .yellow,
        .red
    ])

    /// Medical style: green -> yellow -> red.
    public static let medical = HeatmapColorScale(colors: [
        .green,
        .yellow,
        .red
    ])

    /// Monochrome: light gray -> dark.
    public static let monochrome = HeatmapColorScale(colors: [
        Color(white: 0.85),
        Color(white: 0.15)
    ])

    /// Workout with 5 discrete steps instead of smooth gradient.
    public static let workoutStepped = HeatmapColorScale(
        colors: [.mmDefaultFill, .yellow, .orange, .red],
        interpolation: .step(count: 5)
    )

    /// Thermal with smooth ease-in-out curve.
    public static let thermalSmooth = HeatmapColorScale(
        colors: [.blue, .green, .yellow, .red],
        interpolation: .easeInOut
    )
}
