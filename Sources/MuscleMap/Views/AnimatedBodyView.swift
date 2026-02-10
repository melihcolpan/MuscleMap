//
//  AnimatedBodyView.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A container that animates transitions between highlight states.
struct AnimatedBodyContainer: View {
    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let animationDuration: Double
    let selectionPulseFactor: Double
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?
    let onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragged: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragEnded: (() -> Void)?
    let longPressDuration: Double
    @State private var currentHighlights: [Muscle: MuscleHighlight] = [:]
    @State private var previousHighlights: [Muscle: MuscleHighlight] = [:]
    @State private var progress: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let blended = blendedHighlights(progress: progress)
                let renderer = BodyRenderer(
                    gender: gender,
                    side: side,
                    highlights: blended,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    selectionPulseFactor: selectionPulseFactor
                )
                renderer.render(context: &context, size: size)
            }
            .contentShape(Rectangle())
            .overlay {
                InteractiveBodyOverlay(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    size: geometry.size,
                    onMuscleSelected: onMuscleSelected,
                    onMuscleLongPressed: onMuscleLongPressed,
                    onMuscleDragged: onMuscleDragged,
                    onMuscleDragEnded: onMuscleDragEnded,
                    longPressDuration: longPressDuration
                )
            }
            .overlay {
                BodyAccessibilityOverlay(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    size: geometry.size,
                    onMuscleSelected: onMuscleSelected,
                    onMuscleLongPressed: onMuscleLongPressed
                )
            }
        }
        .onChange(of: highlights) { oldValue, newValue in
            previousHighlights = currentHighlights
            currentHighlights = newValue
            progress = 0
            withAnimation(.easeInOut(duration: animationDuration)) {
                progress = 1.0
            }
        }
        .onAppear {
            currentHighlights = highlights
        }
    }

    /// Blends previous and current highlights based on animation progress.
    private func blendedHighlights(progress: Double) -> [Muscle: MuscleHighlight] {
        guard progress < 1.0 else { return currentHighlights }

        var result: [Muscle: MuscleHighlight] = [:]
        let allMuscles = Set(previousHighlights.keys).union(currentHighlights.keys)

        for muscle in allMuscles {
            let prev = previousHighlights[muscle]
            let curr = currentHighlights[muscle]

            switch (prev, curr) {
            case (nil, let new?):
                // Fade in: opacity goes from 0 to target
                result[muscle] = MuscleHighlight(
                    muscle: muscle,
                    fill: new.fill,
                    opacity: new.opacity * progress
                )
            case (let old?, nil):
                // Fade out: opacity goes from target to 0
                result[muscle] = MuscleHighlight(
                    muscle: muscle,
                    fill: old.fill,
                    opacity: old.opacity * (1.0 - progress)
                )
            case (let old?, let new?):
                // Cross-fade: blend opacity and fill
                let blendedOpacity = old.opacity + (new.opacity - old.opacity) * progress
                let blendedFill = Self.blendFills(from: old.fill, to: new.fill, progress: progress)
                result[muscle] = MuscleHighlight(
                    muscle: muscle,
                    fill: blendedFill,
                    opacity: blendedOpacity
                )
            case (nil, nil):
                break
            }
        }

        return result
    }

    /// Blends two fills together. Only color-to-color fills are interpolated;
    /// mixed fill types use a crossfade switch at the halfway point.
    private static func blendFills(from oldFill: MuscleFill, to newFill: MuscleFill, progress: Double) -> MuscleFill {
        switch (oldFill, newFill) {
        case (.color(let oldColor), .color(let newColor)):
            return .color(oldColor.interpolate(to: newColor, fraction: progress))
        default:
            return progress < 0.5 ? oldFill : newFill
        }
    }
}

/// A dedicated view for pulse animation on selected muscles, avoiding TimelineView generic inference issues.
struct PulseBodyView: View {
    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let pulseSpeed: Double
    let pulseRange: ClosedRange<Double>
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?
    let onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragged: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragEnded: (() -> Void)?
    let longPressDuration: Double
    let tooltipContent: ((Muscle, MuscleSide) -> AnyView)?

    var body: some View {
        TimelineView(.animation) { timeline in
            PulseBodyCanvas(
                gender: gender,
                side: side,
                highlights: highlights,
                style: style,
                selectedMuscles: selectedMuscles,
                date: timeline.date,
                pulseSpeed: pulseSpeed,
                pulseRange: pulseRange,
                onMuscleSelected: onMuscleSelected,
                onMuscleLongPressed: onMuscleLongPressed,
                onMuscleDragged: onMuscleDragged,
                onMuscleDragEnded: onMuscleDragEnded,
                longPressDuration: longPressDuration,
                tooltipContent: tooltipContent
            )
        }
    }
}

/// Inner view that renders the pulsing canvas at a specific timestamp.
private struct PulseBodyCanvas: View {
    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let date: Date
    let pulseSpeed: Double
    let pulseRange: ClosedRange<Double>
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?
    let onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragged: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragEnded: (() -> Void)?
    let longPressDuration: Double
    let tooltipContent: ((Muscle, MuscleSide) -> AnyView)?

    private var pulseFactor: Double {
        let elapsed = date.timeIntervalSinceReferenceDate
        let phase = (sin(elapsed * pulseSpeed * .pi * 2) + 1.0) / 2.0
        return pulseRange.lowerBound + phase * (pulseRange.upperBound - pulseRange.lowerBound)
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let renderer = BodyRenderer(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    selectionPulseFactor: pulseFactor
                )
                renderer.render(context: &context, size: size)
            }
            .contentShape(Rectangle())
            .overlay {
                InteractiveBodyOverlay(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    size: geometry.size,
                    onMuscleSelected: onMuscleSelected,
                    onMuscleLongPressed: onMuscleLongPressed,
                    onMuscleDragged: onMuscleDragged,
                    onMuscleDragEnded: onMuscleDragEnded,
                    longPressDuration: longPressDuration
                )
            }
            .overlay {
                if let tooltipContent, !selectedMuscles.isEmpty {
                    MuscleTooltipOverlay(
                        gender: gender,
                        side: side,
                        highlights: highlights,
                        style: style,
                        selectedMuscles: selectedMuscles,
                        size: geometry.size,
                        content: tooltipContent
                    )
                }
            }
            .overlay {
                BodyAccessibilityOverlay(
                    gender: gender,
                    side: side,
                    highlights: highlights,
                    style: style,
                    selectedMuscles: selectedMuscles,
                    size: geometry.size,
                    onMuscleSelected: onMuscleSelected,
                    onMuscleLongPressed: onMuscleLongPressed
                )
            }
        }
    }
}

/// An animatable wrapper that drives smooth Canvas redraws for opacity transitions.
struct AnimatedBodyCanvas: View, Animatable {
    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    var animationProgress: Double
    let selectionPulseFactor: Double

    var animatableData: Double {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let renderer = BodyRenderer(
                gender: gender,
                side: side,
                highlights: highlights,
                style: style,
                selectedMuscles: selectedMuscles,
                selectionPulseFactor: selectionPulseFactor
            )
            renderer.render(context: &context, size: size)
        }
    }
}
