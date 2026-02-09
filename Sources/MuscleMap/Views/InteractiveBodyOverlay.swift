//
//  InteractiveBodyOverlay.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A transparent overlay that handles all gesture interactions (tap, long press, drag)
/// for a body canvas, performing hit testing against the muscle paths.
struct InteractiveBodyOverlay: View {

    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let size: CGSize
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?
    let onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragged: ((Muscle, MuscleSide) -> Void)?
    let onMuscleDragEnded: (() -> Void)?
    let longPressDuration: Double

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(composedGesture)
    }

    // MARK: - Gesture Composition

    /// Composes gestures with priority: longPress > drag > tap.
    private var composedGesture: AnyGesture<Any> {
        let tapGesture: AnyGesture<Any> = AnyGesture(
            SpatialTapGesture()
                .onEnded { value in
                    handleTap(at: value.location)
                }
                .map { $0 as Any }
        )

        if onMuscleLongPressed != nil && onMuscleDragged != nil {
            return AnyGesture(
                longPressGesture
                    .exclusively(before:
                        dragGesture.exclusively(before: tapGesture)
                    )
                    .map { $0 as Any }
            )
        } else if onMuscleLongPressed != nil {
            return AnyGesture(
                longPressGesture
                    .exclusively(before: tapGesture)
                    .map { $0 as Any }
            )
        } else if onMuscleDragged != nil {
            return AnyGesture(
                dragGesture
                    .exclusively(before: tapGesture)
                    .map { $0 as Any }
            )
        } else {
            return tapGesture
        }
    }

    // MARK: - Individual Gestures

    /// Long press gesture that uses a sequenced approach to get the location.
    private var longPressGesture: AnyGesture<Any> {
        let gesture = LongPressGesture(minimumDuration: longPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { value in
                switch value {
                case .second(true, let drag):
                    if let location = drag?.location {
                        handleLongPress(at: location)
                    }
                default:
                    break
                }
            }
        return AnyGesture(gesture.map { $0 as Any })
    }

    /// Drag gesture for continuous hit testing during drag.
    private var dragGesture: AnyGesture<Any> {
        let gesture = DragGesture(minimumDistance: 1)
            .onChanged { value in
                handleDrag(at: value.location)
            }
            .onEnded { _ in
                onMuscleDragEnded?()
            }
        return AnyGesture(gesture.map { $0 as Any })
    }

    // MARK: - Hit Testing

    private func makeRenderer() -> BodyRenderer {
        BodyRenderer(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscles
        )
    }

    private func handleTap(at location: CGPoint) {
        guard onMuscleSelected != nil else { return }
        let renderer = makeRenderer()
        if let (muscle, muscleSide) = renderer.hitTest(at: location, in: size) {
            onMuscleSelected?(muscle, muscleSide)
        }
    }

    private func handleLongPress(at location: CGPoint) {
        guard onMuscleLongPressed != nil else { return }
        let renderer = makeRenderer()
        if let (muscle, muscleSide) = renderer.hitTest(at: location, in: size) {
            onMuscleLongPressed?(muscle, muscleSide)
        }
    }

    private func handleDrag(at location: CGPoint) {
        guard onMuscleDragged != nil else { return }
        let renderer = makeRenderer()
        if let (muscle, muscleSide) = renderer.hitTest(at: location, in: size) {
            onMuscleDragged?(muscle, muscleSide)
        }
    }
}
