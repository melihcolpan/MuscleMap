//
//  MuscleTooltip.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// An overlay that positions tooltip content above each selected muscle.
struct MuscleTooltipOverlay: View {

    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let size: CGSize
    let content: (Muscle, MuscleSide) -> AnyView

    var body: some View {
        GeometryReader { geometry in
            let renderer = BodyRenderer(
                gender: gender,
                side: side,
                highlights: highlights,
                style: style,
                selectedMuscles: selectedMuscles
            )

            ForEach(Array(selectedMuscles), id: \.self) { muscle in
                if let rect = renderer.boundingRect(for: muscle, in: size) {
                    let tooltipPosition = adjustedPosition(
                        for: rect,
                        in: geometry.size
                    )

                    content(muscle, .both)
                        .fixedSize()
                        .position(tooltipPosition)
                }
            }
        }
        .allowsHitTesting(false)
    }

    /// Calculates tooltip position, shifting away from edges if needed.
    private func adjustedPosition(for muscleRect: CGRect, in viewSize: CGSize) -> CGPoint {
        let tooltipHeight: CGFloat = 40
        let padding: CGFloat = 8

        var x = muscleRect.midX
        var y = muscleRect.minY - tooltipHeight / 2 - padding

        // If tooltip would go above the view, place it below
        if y < tooltipHeight / 2 {
            y = muscleRect.maxY + tooltipHeight / 2 + padding
        }

        // Clamp horizontal position
        x = max(60, min(x, viewSize.width - 60))

        return CGPoint(x: x, y: y)
    }
}
