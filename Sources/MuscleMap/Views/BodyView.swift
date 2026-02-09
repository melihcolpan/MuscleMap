//
//  BodyView.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A SwiftUI view that renders a human body with highlighted muscles.
///
/// ```swift
/// import MuscleMap
///
/// BodyView(gender: .male, side: .front)
///     .highlight(.chest, color: .red)
///     .highlight(.biceps, color: .orange, opacity: 0.8)
///     .onMuscleSelected { muscle, side in
///         print("Tapped \(muscle.displayName) (\(side))")
///     }
/// ```
public struct BodyView: View {

    // MARK: - Properties

    private let gender: BodyGender
    private let side: BodySide
    private var style: BodyViewStyle
    private var highlights: [Muscle: MuscleHighlight]
    private var selectedMuscle: Muscle?
    private var onMuscleSelected: ((Muscle, MuscleSide) -> Void)?

    // MARK: - Initializer

    /// Creates a body view.
    /// - Parameters:
    ///   - gender: Male or female body model (default: `.male`).
    ///   - side: Front or back view (default: `.front`).
    ///   - style: Visual style configuration (default: `.default`).
    public init(
        gender: BodyGender = .male,
        side: BodySide = .front,
        style: BodyViewStyle = .default
    ) {
        self.gender = gender
        self.side = side
        self.style = style
        self.highlights = [:]
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let renderer = BodyRenderer(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscle: selectedMuscle
                )
                renderer.render(context: &context, size: size)
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                guard onMuscleSelected != nil else { return }
                let renderer = BodyRenderer(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscle: selectedMuscle
                )
                if let (muscle, muscleSide) = renderer.hitTest(at: location, in: geometry.size) {
                    onMuscleSelected?(muscle, muscleSide)
                }
            }
        }
    }
}

// MARK: - Modifiers

extension BodyView {

    /// Highlights a specific muscle with a color.
    public func highlight(_ muscle: Muscle, color: Color = .red, opacity: Double = 1.0) -> BodyView {
        var copy = self
        copy.highlights[muscle] = MuscleHighlight(muscle: muscle, color: color, opacity: opacity)
        return copy
    }

    /// Highlights multiple muscles with the same color.
    public func highlight(_ muscles: [Muscle], color: Color = .red, opacity: Double = 1.0) -> BodyView {
        var copy = self
        for muscle in muscles {
            copy.highlights[muscle] = MuscleHighlight(muscle: muscle, color: color, opacity: opacity)
        }
        return copy
    }

    /// Applies heatmap data using a color scale.
    public func heatmap(_ data: [MuscleIntensity], colorScale: HeatmapColorScale = .workout) -> BodyView {
        var copy = self
        for entry in data {
            let color = entry.color ?? colorScale.color(for: entry.intensity)
            copy.highlights[entry.muscle] = MuscleHighlight(
                muscle: entry.muscle,
                color: color,
                opacity: 1.0
            )
        }
        return copy
    }

    /// Applies intensity-based highlighting (0-4 scale, like workout trackers).
    public func intensities(_ data: [Muscle: Int], colorScale: HeatmapColorScale = .workout) -> BodyView {
        var copy = self
        for (muscle, level) in data {
            let normalizedIntensity = Double(min(max(level, 0), 4)) / 4.0
            let color = colorScale.color(for: normalizedIntensity)
            copy.highlights[muscle] = MuscleHighlight(muscle: muscle, color: color, opacity: 1.0)
        }
        return copy
    }

    /// Sets the selected muscle (displayed with selection style).
    public func selected(_ muscle: Muscle?) -> BodyView {
        var copy = self
        copy.selectedMuscle = muscle
        return copy
    }

    /// Sets a callback for when a muscle is tapped.
    public func onMuscleSelected(_ action: @escaping (Muscle, MuscleSide) -> Void) -> BodyView {
        var copy = self
        copy.onMuscleSelected = action
        return copy
    }

    /// Applies a custom style.
    public func bodyStyle(_ style: BodyViewStyle) -> BodyView {
        var copy = self
        copy.style = style
        return copy
    }
}

// MARK: - Preview

#Preview("Male Front") {
    BodyView(gender: .male, side: .front)
        .highlight(.chest, color: .red)
        .highlight(.biceps, color: .orange, opacity: 0.8)
        .highlight(.abs, color: .yellow, opacity: 0.6)
        .highlight(.quadriceps, color: .red)
        .frame(width: 200, height: 400)
        .padding()
}

#Preview("Male Back") {
    BodyView(gender: .male, side: .back)
        .highlight(.trapezius, color: .orange)
        .highlight(.upperBack, color: .red)
        .highlight(.hamstring, color: .red)
        .frame(width: 200, height: 400)
        .padding()
}

#Preview("Female Front") {
    BodyView(gender: .female, side: .front)
        .highlight(.chest, color: .pink)
        .highlight(.abs, color: .orange)
        .highlight(.quadriceps, color: .red)
        .frame(width: 200, height: 400)
        .padding()
}

#Preview("Heatmap") {
    BodyView(gender: .male, side: .front)
        .intensities([
            .chest: 3,
            .biceps: 2,
            .abs: 1,
            .quadriceps: 4,
            .deltoids: 2
        ])
        .frame(width: 200, height: 400)
        .padding()
}
