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
    let selectedMuscles: Set<Muscle>
    var selectionPulseFactor: Double = 1.0

    /// Primary initializer with multi-select support.
    init(
        gender: BodyGender,
        side: BodySide,
        highlights: [Muscle: MuscleHighlight],
        style: BodyViewStyle,
        selectedMuscles: Set<Muscle>,
        selectionPulseFactor: Double = 1.0
    ) {
        self.gender = gender
        self.side = side
        self.highlights = highlights
        self.style = style
        self.selectedMuscles = selectedMuscles
        self.selectionPulseFactor = selectionPulseFactor
    }

    /// Backward-compatible initializer accepting optional single muscle.
    init(
        gender: BodyGender,
        side: BodySide,
        highlights: [Muscle: MuscleHighlight],
        style: BodyViewStyle,
        selectedMuscle: Muscle?,
        selectionPulseFactor: Double = 1.0
    ) {
        self.init(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscle.map { Set([$0]) } ?? [],
            selectionPulseFactor: selectionPulseFactor
        )
    }

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
        let hasShadow = style.shadowRadius > 0

        for bodyPart in bodyParts {
            let muscle = bodyPart.slug.muscle
            let highlight = muscle.flatMap { highlights[$0] }
            let isSelected = muscle.map { selectedMuscles.contains($0) } ?? false

            let fill = resolveFill(
                for: bodyPart.slug,
                highlight: highlight,
                isSelected: isSelected
            )

            let highlightOpacity = highlight?.opacity ?? 1.0
            let needsOpacityLayer = highlightOpacity < 1.0 && highlight != nil
            let needsShadow = hasShadow && highlight != nil

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

                let boundingRect = path.boundingRect
                let shading = fill.shading(in: boundingRect)

                if needsShadow || needsOpacityLayer {
                    context.drawLayer { layerContext in
                        if needsShadow {
                            layerContext.addFilter(.shadow(
                                color: style.shadowColor,
                                radius: style.shadowRadius,
                                x: style.shadowOffset.width,
                                y: style.shadowOffset.height
                            ))
                        }
                        if needsOpacityLayer {
                            layerContext.opacity = highlightOpacity
                        }
                        if isSelected && selectionPulseFactor != 1.0 {
                            layerContext.opacity *= selectionPulseFactor
                        }
                        layerContext.fill(path, with: shading)
                    }
                } else {
                    if isSelected && selectionPulseFactor != 1.0 {
                        context.drawLayer { layerContext in
                            layerContext.opacity = selectionPulseFactor
                            layerContext.fill(path, with: shading)
                        }
                    } else {
                        context.fill(path, with: shading)
                    }
                }

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

    /// Returns the bounding rect of a muscle's combined paths in the given view size.
    func boundingRect(for muscle: Muscle, in size: CGSize) -> CGRect? {
        let viewBox = BodyPathProvider.viewBox(gender: gender, side: side)
        let scale = min(
            size.width / viewBox.size.width,
            size.height / viewBox.size.height
        )
        let offsetX = (size.width - viewBox.size.width * scale) / 2 - viewBox.origin.x * scale
        let offsetY = (size.height - viewBox.size.height * scale) / 2 - viewBox.origin.y * scale

        let bodyParts = BodyPathProvider.paths(gender: gender, side: side)
        var combinedRect: CGRect?

        for bodyPart in bodyParts {
            guard bodyPart.slug.muscle == muscle else { continue }
            for pathString in bodyPart.allPaths {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                let rect = path.boundingRect
                guard !rect.isEmpty else { continue }
                if let existing = combinedRect {
                    combinedRect = existing.union(rect)
                } else {
                    combinedRect = rect
                }
            }
        }

        return combinedRect
    }

    // MARK: - Private

    private func resolveFill(
        for slug: BodySlug,
        highlight: MuscleHighlight?,
        isSelected: Bool
    ) -> MuscleFill {
        if slug == .hair {
            return .color(style.hairColor)
        }
        if slug == .head {
            return .color(style.headColor)
        }
        if isSelected {
            return .color(style.selectionColor)
        }
        if let highlight {
            return highlight.fill
        }
        return .color(style.defaultFillColor)
    }
}
