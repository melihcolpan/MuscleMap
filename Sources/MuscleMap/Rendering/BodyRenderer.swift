//
//  BodyRenderer.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BodyRenderer {

    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscle: Muscle?

    private let pathCache = PathCache()

    func render(context: inout GraphicsContext, size: CGSize) {
        let viewBox = BodyPathProvider.viewBox(gender: gender, side: side)
        let scale = min(
            size.width / viewBox.size.width,
            size.height / viewBox.size.height
        )
        let offsetX = (size.width - viewBox.size.width * scale) / 2 - viewBox.origin.x * scale
        let offsetY = (size.height - viewBox.size.height * scale) / 2 - viewBox.origin.y * scale

        let bodyParts = BodyPathProvider.paths(gender: gender, side: side)

        for bodyPart in bodyParts {
            let muscle = bodyPart.slug.muscle
            let highlight = muscle.flatMap { highlights[$0] }
            let isSelected = muscle != nil && selectedMuscle == muscle

            let fillColor = resolveColor(
                for: bodyPart.slug,
                highlight: highlight,
                isSelected: isSelected
            )

            let allPaths: [(String, MuscleSide)] =
                bodyPart.common.map { ($0, .both) } +
                bodyPart.left.map { ($0, .left) } +
                bodyPart.right.map { ($0, .right) }

            for (pathString, _) in allPaths {
                let path = pathCache.path(
                    for: pathString,
                    scale: scale,
                    offsetX: offsetX,
                    offsetY: offsetY
                )
                context.fill(path, with: .color(fillColor))

                if style.strokeWidth > 0 {
                    context.stroke(
                        path,
                        with: .color(style.strokeColor),
                        lineWidth: style.strokeWidth
                    )
                }

                if isSelected {
                    context.stroke(
                        path,
                        with: .color(style.selectionStrokeColor),
                        lineWidth: style.selectionStrokeWidth
                    )
                }
            }
        }
    }

    /// Find which muscle was tapped at the given point.
    func hitTest(at point: CGPoint, in size: CGSize) -> (Muscle, MuscleSide)? {
        let viewBox = BodyPathProvider.viewBox(gender: gender, side: side)
        let scale = min(
            size.width / viewBox.size.width,
            size.height / viewBox.size.height
        )
        let offsetX = (size.width - viewBox.size.width * scale) / 2 - viewBox.origin.x * scale
        let offsetY = (size.height - viewBox.size.height * scale) / 2 - viewBox.origin.y * scale

        let bodyParts = BodyPathProvider.paths(gender: gender, side: side)

        for bodyPart in bodyParts {
            guard let muscle = bodyPart.slug.muscle else { continue }

            for pathString in bodyPart.left {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (muscle, .left) }
            }

            for pathString in bodyPart.right {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (muscle, .right) }
            }

            for pathString in bodyPart.common {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (muscle, .both) }
            }
        }

        return nil
    }

    // MARK: - Private

    private func resolveColor(
        for slug: BodySlug,
        highlight: MuscleHighlight?,
        isSelected: Bool
    ) -> Color {
        if slug == .hair {
            return style.hairColor
        }
        if slug == .head {
            return style.headColor
        }
        if isSelected {
            return style.selectionColor
        }
        if let highlight {
            return highlight.color.opacity(highlight.opacity)
        }
        return style.defaultFillColor
    }
}
