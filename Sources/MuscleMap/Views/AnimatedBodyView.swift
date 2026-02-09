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
    let selectedMuscle: Muscle?
    let animationDuration: Double
    let selectionPulseFactor: Double
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?

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
                    selectedMuscle: selectedMuscle,
                    selectionPulseFactor: selectionPulseFactor
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
                // Cross-fade: blend opacity
                let blendedOpacity = old.opacity + (new.opacity - old.opacity) * progress
                result[muscle] = MuscleHighlight(
                    muscle: muscle,
                    fill: new.fill,
                    opacity: blendedOpacity
                )
            case (nil, nil):
                break
            }
        }

        return result
    }
}

/// An animatable wrapper that drives smooth Canvas redraws for opacity transitions.
struct AnimatedBodyCanvas: View, Animatable {
    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscle: Muscle?
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
                selectedMuscle: selectedMuscle,
                selectionPulseFactor: selectionPulseFactor
            )
            renderer.render(context: &context, size: size)
        }
    }
}
