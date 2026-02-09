//
//  ZoomableBodyContainer.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A container that adds pinch-to-zoom and pan capabilities to its content.
struct ZoomableBodyContainer<Content: View>: View {

    let minScale: CGFloat
    let maxScale: CGFloat
    @ViewBuilder let content: (_ currentScale: CGFloat, _ currentOffset: CGSize) -> Content

    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        let effectiveScale = clampedScale(currentScale * pinchScale)
        let effectiveOffset = CGSize(
            width: currentOffset.width + dragOffset.width,
            height: currentOffset.height + dragOffset.height
        )

        content(effectiveScale, effectiveOffset)
            .scaleEffect(effectiveScale)
            .offset(effectiveOffset)
            .gesture(
                MagnifyGesture()
                    .updating($pinchScale) { value, state, _ in
                        state = value.magnification
                    }
                    .onEnded { value in
                        currentScale = clampedScale(currentScale * value.magnification)
                        // Reset offset if zoomed back to 1x
                        if currentScale <= minScale {
                            currentOffset = .zero
                        }
                    }
                    .simultaneously(with:
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                currentOffset = CGSize(
                                    width: currentOffset.width + value.translation.width,
                                    height: currentOffset.height + value.translation.height
                                )
                            }
                    )
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentScale > minScale {
                        currentScale = minScale
                        currentOffset = .zero
                    } else {
                        currentScale = min(2.0, maxScale)
                    }
                }
            }
    }

    private func clampedScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, minScale), maxScale)
    }
}
