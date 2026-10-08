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
    let hideSubGroups: Bool

    /// Primary initializer with multi-select support.
    init(
        gender: BodyGender,
        side: BodySide,
        highlights: [Muscle: MuscleHighlight],
        style: BodyViewStyle,
        selectedMuscles: Set<Muscle>,
        selectionPulseFactor: Double = 1.0,
        hideSubGroups: Bool = true
    ) {
        self.gender = gender
        self.side = side
        self.highlights = highlights
        self.style = style
        self.selectedMuscles = selectedMuscles
        self.selectionPulseFactor = selectionPulseFactor
        self.hideSubGroups = hideSubGroups
    }

    /// Backward-compatible initializer accepting optional single muscle.
    init(
        gender: BodyGender,
        side: BodySide,
        highlights: [Muscle: MuscleHighlight],
        style: BodyViewStyle,
        selectedMuscle: Muscle?,
        selectionPulseFactor: Double = 1.0,
        hideSubGroups: Bool = true
    ) {
        self.init(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscle.map { Set([$0]) } ?? [],
            selectionPulseFactor: selectionPulseFactor,
            hideSubGroups: hideSubGroups
        )
    }

    /// Shared across renderers: a `BodyRenderer` is rebuilt on every Canvas draw,
    /// so an instance-owned cache would never serve a hit.
    static let sharedPathCache = PathCache()

    private var pathCache: PathCache { Self.sharedPathCache }

    private static let preloadOnce: Void = {
        Task.detached(priority: .utility) {
            for gender in BodyGender.allCases {
                for side in BodySide.allCases {
                    sharedPathCache.preload(BodyPathProvider.paths(gender: gender, side: side).flatMap(\.allPaths))
                }
            }
        }
    }()

    /// Starts parsing the artwork of all four bodies in the background, once per app run.
    static func preloadArtwork() {
        _ = preloadOnce
    }

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
            if hideSubGroups, let m = bodyPart.slug.muscle, m.isSubGroup, !m.isAlwaysVisibleSubGroup { continue }

            let muscle = bodyPart.slug.muscle
            let highlight = muscle.flatMap { highlights[$0] }
            if let m = muscle, m.isOverlayRegion, highlight == nil, !selectedMuscles.contains(m) { continue }
            let isSelected: Bool = {
                guard let m = muscle else { return false }
                if selectedMuscles.contains(m) { return true }
                if hideSubGroups, let host = m.defaultModeHost {
                    return selectedMuscles.contains(host)
                }
                return false
            }()

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
    /// Sub-groups are tested before their parent groups.
    func hitTest(at point: CGPoint, in size: CGSize) -> (Muscle, MuscleSide)? {
        let viewBox = BodyPathProvider.viewBox(gender: gender, side: side)
        let scale = min(
            size.width / viewBox.size.width,
            size.height / viewBox.size.height
        )
        let offsetX = (size.width - viewBox.size.width * scale) / 2 - viewBox.origin.x * scale
        let offsetY = (size.height - viewBox.size.height * scale) / 2 - viewBox.origin.y * scale

        let bodyParts = BodyPathProvider.paths(gender: gender, side: side)

        // Test sub-groups (and overlay regions) first so they take priority over parent groups
        let sortedParts = bodyParts.sorted { a, b in
            // Overlay regions sit on top of their host, so they are tested first as well
            let aIsSub = a.slug.muscle.map { $0.isSubGroup || $0.isOverlayRegion } ?? false
            let bIsSub = b.slug.muscle.map { $0.isSubGroup || $0.isOverlayRegion } ?? false
            if aIsSub != bIsSub { return aIsSub }
            return false
        }

        for bodyPart in sortedParts {
            guard let muscle = bodyPart.slug.muscle else { continue }
            if hideSubGroups && muscle.isSubGroup && !muscle.isAlwaysVisibleSubGroup { continue }

            // Always-visible sub-groups return parent when sub-groups are hidden
            let resolvedMuscle: Muscle
            if hideSubGroups, let host = muscle.defaultModeHost {
                resolvedMuscle = host
            } else {
                resolvedMuscle = muscle
            }

            for pathString in bodyPart.left {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (resolvedMuscle, .left) }
            }

            for pathString in bodyPart.right {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (resolvedMuscle, .right) }
            }

            for pathString in bodyPart.common {
                let path = pathCache.path(for: pathString, scale: scale, offsetX: offsetX, offsetY: offsetY)
                if path.contains(point) { return (resolvedMuscle, .both) }
            }
        }

        return nil
    }

    /// Returns the bounding rect of a muscle's combined paths in the given view size.
    func boundingRect(for muscle: Muscle, in size: CGSize) -> CGRect? {
        boundingRect(for: muscle, muscleSide: nil, in: size)
    }

    /// Returns the bounding rect of one side of a muscle (`.both` = its common paths),
    /// or of all its paths when `muscleSide` is nil.
    func boundingRect(for muscle: Muscle, muscleSide: MuscleSide?, in size: CGSize) -> CGRect? {
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
            guard let partMuscle = bodyPart.slug.muscle,
                  partMuscle == muscle || partMuscle.regionHost == muscle else { continue }
            let paths: [String]
            switch muscleSide {
            case nil: paths = bodyPart.allPaths
            case .left: paths = bodyPart.left
            case .right: paths = bodyPart.right
            case .both: paths = bodyPart.common
            }
            for pathString in paths {
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
        // Sub-group / carved-region inheritance: if no highlight of its own, use the parent's or host's
        if let muscle = slug.muscle, let parent = muscle.parentGroup ?? muscle.regionHost,
           let parentHighlight = highlights[parent] {
            return parentHighlight.fill
        }
        return .color(style.defaultFillColor)
    }
}
