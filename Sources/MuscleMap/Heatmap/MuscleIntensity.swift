//
//  MuscleIntensity.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Represents the intensity level for a specific muscle.
public struct MuscleIntensity: Sendable {
    public let muscle: Muscle
    public let intensity: Double
    public let side: MuscleSide
    public let color: Color?

    /// Creates a muscle intensity entry.
    /// - Parameters:
    ///   - muscle: The target muscle.
    ///   - intensity: Intensity value from 0.0 (none) to 1.0 (maximum).
    ///   - side: Which side of the body (default: both).
    ///   - color: Optional override color. If nil, the heatmap color scale is used.
    public init(
        muscle: Muscle,
        intensity: Double,
        side: MuscleSide = .both,
        color: Color? = nil
    ) {
        self.muscle = muscle
        self.intensity = min(max(intensity, 0), 1)
        self.side = side
        self.color = color
    }
}

/// Data model for a highlighted muscle with color and opacity.
public struct MuscleHighlight: Sendable {
    public let muscle: Muscle
    public let color: Color
    public let opacity: Double

    public init(muscle: Muscle, color: Color, opacity: Double = 1.0) {
        self.muscle = muscle
        self.color = color
        self.opacity = opacity
    }
}
