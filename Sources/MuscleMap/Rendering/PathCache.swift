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

    private var cache: [String: Path] = [:]
    private let lock = NSLock()

    func path(
        for svgPath: String,
        scale: CGFloat,
        offsetX: CGFloat,
        offsetY: CGFloat
    ) -> Path {
        let key = "\(svgPath.hashValue)-\(scale)-\(offsetX)-\(offsetY)"

        lock.lock()
        if let cached = cache[key] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        let built = PathBuilder.buildPath(from: svgPath, scale: scale, offsetX: offsetX, offsetY: offsetY)

        lock.lock()
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
