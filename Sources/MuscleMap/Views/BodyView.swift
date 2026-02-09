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
    private var selectedMuscles: Set<Muscle> = []
    private var onMuscleSelected: ((Muscle, MuscleSide) -> Void)?

    // Animation
    private var isAnimated: Bool = false
    private var animationDuration: Double = 0.3

    // Pulse
    private var isPulseEnabled: Bool = false
    private var pulseSpeed: Double = 1.5
    private var pulseRange: ClosedRange<Double> = 0.6...1.0

    // Gestures
    private var onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    private var onMuscleDragged: ((Muscle, MuscleSide) -> Void)?
    private var onMuscleDragEnded: (() -> Void)?
    private var longPressDuration: Double = 0.5

    // Zoom
    private var isZoomEnabled: Bool = false
    private var minZoomScale: CGFloat = 1.0
    private var maxZoomScale: CGFloat = 4.0

    // Tooltip
    private var tooltipContent: ((Muscle, MuscleSide) -> AnyView)?

    // Undo
    private var selectionHistory: SelectionHistory?

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
        if isZoomEnabled {
            zoomableBody
        } else if isPulseEnabled && !selectedMuscles.isEmpty {
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
                makeRenderer(size: size).render(context: &context, size: size)
            }
            .contentShape(Rectangle())
            .overlay {
                makeInteractiveOverlay(size: geometry.size)
            }
            .overlay {
                makeTooltipOverlay(size: geometry.size)
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
            selectedMuscles: selectedMuscles,
            animationDuration: animationDuration,
            selectionPulseFactor: 1.0,
            onMuscleSelected: wrappedOnMuscleSelected,
            onMuscleLongPressed: onMuscleLongPressed,
            onMuscleDragged: onMuscleDragged,
            onMuscleDragEnded: onMuscleDragEnded,
            longPressDuration: longPressDuration
        )
    }

    @ViewBuilder
    private var pulseBody: some View {
        PulseBodyView(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscles,
            pulseSpeed: pulseSpeed,
            pulseRange: pulseRange,
            onMuscleSelected: wrappedOnMuscleSelected,
            onMuscleLongPressed: onMuscleLongPressed,
            onMuscleDragged: onMuscleDragged,
            onMuscleDragEnded: onMuscleDragEnded,
            longPressDuration: longPressDuration,
            tooltipContent: tooltipContent
        )
    }

    @ViewBuilder
    private var zoomableBody: some View {
        ZoomableBodyContainer(
            minScale: minZoomScale,
            maxScale: maxZoomScale
        ) { _, _ in
            if isPulseEnabled && !selectedMuscles.isEmpty {
                PulseBodyView(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    pulseSpeed: pulseSpeed,
                    pulseRange: pulseRange,
                    onMuscleSelected: wrappedOnMuscleSelected,
                    onMuscleLongPressed: onMuscleLongPressed,
                    onMuscleDragged: onMuscleDragged,
                    onMuscleDragEnded: onMuscleDragEnded,
                    longPressDuration: longPressDuration,
                    tooltipContent: tooltipContent
                )
            } else {
                standardBody
            }
        }
    }

    // MARK: - Helpers

    private func makeRenderer(size: CGSize) -> BodyRenderer {
        BodyRenderer(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscles
        )
    }

    private func makeInteractiveOverlay(size: CGSize) -> InteractiveBodyOverlay {
        InteractiveBodyOverlay(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscles,
            size: size,
            onMuscleSelected: wrappedOnMuscleSelected,
            onMuscleLongPressed: onMuscleLongPressed,
            onMuscleDragged: onMuscleDragged,
            onMuscleDragEnded: onMuscleDragEnded,
            longPressDuration: longPressDuration
        )
    }

    @ViewBuilder
    private func makeTooltipOverlay(size: CGSize) -> some View {
        if let tooltipContent, !selectedMuscles.isEmpty {
            MuscleTooltipOverlay(
                gender: gender,
                side: side,
                highlights: highlights,
                style: style,
                selectedMuscles: selectedMuscles,
                size: size,
                content: tooltipContent
            )
        }
    }

    /// Wraps `onMuscleSelected` to also push to history if `.undoable()` is enabled.
    private var wrappedOnMuscleSelected: ((Muscle, MuscleSide) -> Void)? {
        guard onMuscleSelected != nil || selectionHistory != nil else { return nil }
        return { muscle, side in
            onMuscleSelected?(muscle, side)
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

    /// Sets the selected muscle (backward compatible, single muscle).
    public func selected(_ muscle: Muscle?) -> BodyView {
        var copy = self
        copy.selectedMuscles = muscle.map { Set([$0]) } ?? []
        return copy
    }

    /// Sets multiple selected muscles (multi-select).
    public func selected(_ muscles: Set<Muscle>) -> BodyView {
        var copy = self
        copy.selectedMuscles = muscles
        return copy
    }

    /// Sets a callback for when a muscle is tapped.
    public func onMuscleSelected(_ action: @escaping (Muscle, MuscleSide) -> Void) -> BodyView {
        var copy = self
        copy.onMuscleSelected = action
        return copy
    }

    /// Sets a callback for when a muscle is long pressed.
    public func onMuscleLongPressed(duration: Double = 0.5, action: @escaping (Muscle, MuscleSide) -> Void) -> BodyView {
        var copy = self
        copy.longPressDuration = duration
        copy.onMuscleLongPressed = action
        return copy
    }

    /// Sets a callback for drag-to-select gesture.
    public func onMuscleDragged(_ action: @escaping (Muscle, MuscleSide) -> Void, onEnded: @escaping () -> Void = {}) -> BodyView {
        var copy = self
        copy.onMuscleDragged = action
        copy.onMuscleDragEnded = onEnded
        return copy
    }

    /// Enables pinch-to-zoom and pan.
    public func zoomable(minScale: CGFloat = 1.0, maxScale: CGFloat = 4.0) -> BodyView {
        var copy = self
        copy.isZoomEnabled = true
        copy.minZoomScale = minScale
        copy.maxZoomScale = maxScale
        return copy
    }

    /// Adds a tooltip overlay that appears above selected muscles.
    public func tooltip<Content: View>(@ViewBuilder content: @escaping (Muscle, MuscleSide) -> Content) -> BodyView {
        var copy = self
        copy.tooltipContent = { muscle, side in AnyView(content(muscle, side)) }
        return copy
    }

    /// Enables undo/redo tracking with the provided history object.
    public func undoable(_ history: SelectionHistory) -> BodyView {
        var copy = self
        copy.selectionHistory = history
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
