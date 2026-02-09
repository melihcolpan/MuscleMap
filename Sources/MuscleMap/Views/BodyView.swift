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

    // Animation
    private var isAnimated: Bool = false
    private var animationDuration: Double = 0.3

    // Pulse
    private var isPulseEnabled: Bool = false
    private var pulseSpeed: Double = 1.5
    private var pulseRange: ClosedRange<Double> = 0.6...1.0

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
        if isPulseEnabled && selectedMuscle != nil {
            pulseBody
        } else if isAnimated {
            animatedBody
        } else {
            standardBody
        }
    }

    // MARK: - Body Variants

    @ViewBuilder
    private var standardBody: some View {
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
                handleTap(at: location, in: geometry.size)
            }
        }
    }

    @ViewBuilder
    private var animatedBody: some View {
        AnimatedBodyContainer(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscle: selectedMuscle,
            animationDuration: animationDuration,
            selectionPulseFactor: 1.0,
            onMuscleSelected: onMuscleSelected
        )
    }

    @ViewBuilder
    private var pulseBody: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geometry in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                let phase = (sin(elapsed * pulseSpeed * .pi * 2) + 1.0) / 2.0
                let pulseFactor = pulseRange.lowerBound + phase * (pulseRange.upperBound - pulseRange.lowerBound)

                Canvas { context, size in
                    let renderer = BodyRenderer(
                        gender: gender,
                        side: side,
                        highlights: highlights,
                        style: style,
                        selectedMuscle: selectedMuscle,
                        selectionPulseFactor: pulseFactor
                    )
                    renderer.render(context: &context, size: size)
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTap(at: location, in: geometry.size)
                }
            }
        }
    }

    // MARK: - Private

    private func handleTap(at location: CGPoint, in size: CGSize) {
        guard onMuscleSelected != nil else { return }
        let renderer = BodyRenderer(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscle: selectedMuscle
        )
        if let (muscle, muscleSide) = renderer.hitTest(at: location, in: size) {
            onMuscleSelected?(muscle, muscleSide)
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

    /// Highlights a muscle with a linear gradient.
    public func highlight(
        _ muscle: Muscle,
        linearGradient colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom,
        opacity: Double = 1.0
    ) -> BodyView {
        var copy = self
        copy.highlights[muscle] = MuscleHighlight(
            muscle: muscle,
            fill: .linearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint),
            opacity: opacity
        )
        return copy
    }

    /// Highlights a muscle with a radial gradient.
    public func highlight(
        _ muscle: Muscle,
        radialGradient colors: [Color],
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 40,
        opacity: Double = 1.0
    ) -> BodyView {
        var copy = self
        copy.highlights[muscle] = MuscleHighlight(
            muscle: muscle,
            fill: .radialGradient(colors: colors, center: center, startRadius: startRadius, endRadius: endRadius),
            opacity: opacity
        )
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

    /// Enables smooth fade-in/fade-out animation when highlights change.
    public func animated(duration: Double = 0.3) -> BodyView {
        var copy = self
        copy.isAnimated = true
        copy.animationDuration = duration
        return copy
    }

    /// Enables pulse animation on the selected muscle.
    public func pulseSelected(speed: Double = 1.5, range: ClosedRange<Double> = 0.6...1.0) -> BodyView {
        var copy = self
        copy.isPulseEnabled = true
        copy.pulseSpeed = speed
        copy.pulseRange = range
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

#Preview("Gradient") {
    BodyView(gender: .male, side: .front)
        .highlight(.chest, linearGradient: [.red, .orange], startPoint: .top, endPoint: .bottom)
        .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 40)
        .highlight(.quadriceps, color: .red)
        .frame(width: 200, height: 400)
        .padding()
}
