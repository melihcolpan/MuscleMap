//
//  PathCache.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

final class PathCache: @unchecked Sendable {

    private struct Key: Hashable {
        let svgPath: String
        let scale: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
    }

    private var cache: [Key: Path] = [:]
    private let lock = NSLock()
    private let maxEntries: Int

    /// - Parameter maxEntries: The cache is cleared once it grows past this size,
    ///   which bounds memory when a body is drawn at many sizes (e.g. while zooming).
    init(maxEntries: Int = 4096) {
        self.maxEntries = maxEntries
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    func path(
        for svgPath: String,
        scale: CGFloat,
        offsetX: CGFloat,
        offsetY: CGFloat
    ) -> Path {
        let key = Key(svgPath: svgPath, scale: scale, offsetX: offsetX, offsetY: offsetY)

        lock.lock()
        if let cached = cache[key] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        let built = PathBuilder.buildPath(from: svgPath, scale: scale, offsetX: offsetX, offsetY: offsetY)

        lock.lock()
        if cache.count >= maxEntries {
            cache.removeAll(keepingCapacity: true)
        }
        cache[key] = built
        lock.unlock()

        return built
    }

    func invalidate() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }
}
