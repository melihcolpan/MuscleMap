//
//  PathCache.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import os

/// Caches parsed body paths.
///
/// Each SVG path string is parsed once at unit scale, then scaled and offset per
/// view size, which is much cheaper than parsing again. The parsed paths are kept
/// for the life of the app (the artwork is a fixed set of strings); the per-size
/// copies are cleared once they pass `maxEntries`.
final class PathCache: Sendable {

    private struct SizedKey: Hashable {
        let svgPath: String
        let scale: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
    }

    private struct State {
        var unit: [String: Path] = [:]
        var sized: [SizedKey: Path] = [:]
    }

    private let state = OSAllocatedUnfairLock(initialState: State())
    private let maxEntries: Int

    /// - Parameter maxEntries: The per-size cache is cleared once it grows past this size,
    ///   which bounds memory when a body is drawn at many sizes (e.g. while zooming).
    init(maxEntries: Int = 4096) {
        self.maxEntries = maxEntries
    }

    /// Number of per-size paths currently cached.
    var count: Int {
        state.withLock { $0.sized.count }
    }

    /// Number of path strings parsed so far.
    var parsedCount: Int {
        state.withLock { $0.unit.count }
    }

    func path(
        for svgPath: String,
        scale: CGFloat,
        offsetX: CGFloat,
        offsetY: CGFloat
    ) -> Path {
        let key = SizedKey(svgPath: svgPath, scale: scale, offsetX: offsetX, offsetY: offsetY)
        if let cached = state.withLock({ $0.sized[key] }) {
            return cached
        }

        let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: offsetX, ty: offsetY)
        let built = unitPath(for: svgPath).applying(transform)

        let limit = maxEntries
        state.withLock { state in
            if state.sized.count >= limit {
                state.sized.removeAll(keepingCapacity: true)
            }
            state.sized[key] = built
        }
        return built
    }

    /// Parses the given path strings ahead of time so later draws only scale them.
    func preload(_ svgPaths: [String]) {
        for svgPath in svgPaths {
            _ = unitPath(for: svgPath)
        }
    }

    func invalidate() {
        state.withLock { $0 = State() }
    }

    private func unitPath(for svgPath: String) -> Path {
        if let cached = state.withLock({ $0.unit[svgPath] }) {
            return cached
        }
        let built = PathBuilder.buildPath(from: svgPath, scale: 1, offsetX: 0, offsetY: 0)
        state.withLock { $0.unit[svgPath] = built }
        return built
    }
}
