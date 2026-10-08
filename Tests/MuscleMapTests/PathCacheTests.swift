import XCTest
import SwiftUI
@testable import MuscleMap

final class PathCacheTests: XCTestCase {

    func testCacheReturnsSamePath() {
        let cache = PathCache()
        let svg = "M 0 0 L 100 100"
        let path1 = cache.path(for: svg, scale: 1.0, offsetX: 0, offsetY: 0)
        let path2 = cache.path(for: svg, scale: 1.0, offsetX: 0, offsetY: 0)
        // Both should be equivalent (cached)
        XCTAssertEqual(path1.boundingRect, path2.boundingRect)
    }

    func testCacheDifferentScalesAreDifferent() {
        let cache = PathCache()
        let svg = "M 0 0 L 100 100"
        let path1 = cache.path(for: svg, scale: 1.0, offsetX: 0, offsetY: 0)
        let path2 = cache.path(for: svg, scale: 2.0, offsetX: 0, offsetY: 0)
        XCTAssertNotEqual(path1.boundingRect, path2.boundingRect)
    }

    func testCacheInvalidation() {
        let cache = PathCache()
        let svg = "M 0 0 L 100 100"
        let _ = cache.path(for: svg, scale: 1.0, offsetX: 0, offsetY: 0)
        cache.invalidate()
        // After invalidation, should still work (rebuild from scratch)
        let path = cache.path(for: svg, scale: 1.0, offsetX: 0, offsetY: 0)
        XCTAssertFalse(path.isEmpty)
    }

    func testCacheThreadSafety() {
        let cache = PathCache()
        let svg = "M 0 0 L 100 100 Z"
        let expectation = XCTestExpectation(description: "Concurrent cache access")
        expectation.expectedFulfillmentCount = 10

        for i in 0..<10 {
            DispatchQueue.global().async {
                let scale = CGFloat(i + 1) * 0.1
                let _ = cache.path(for: svg, scale: scale, offsetX: 0, offsetY: 0)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

final class SharedPathCacheTests: XCTestCase {

    func testCacheIsSharedAcrossRenderers() {
        let cache = BodyRenderer.sharedPathCache
        cache.invalidate()
        let size = CGSize(width: 200, height: 400)
        let make = { BodyRenderer(gender: .male, side: .front, highlights: [:], style: .default, selectedMuscles: []) }
        _ = make().boundingRect(for: .chest, in: size)
        let afterFirst = cache.count
        XCTAssertGreaterThan(afterFirst, 0)
        _ = make().boundingRect(for: .chest, in: size)
        XCTAssertEqual(cache.count, afterFirst, "a second renderer should reuse the cached paths")
    }

    func testCacheIsBounded() {
        let cache = PathCache(maxEntries: 3)
        for i in 0..<10 {
            _ = cache.path(for: "M 0 0 L 100 100", scale: CGFloat(i + 1), offsetX: 0, offsetY: 0)
        }
        XCTAssertLessThanOrEqual(cache.count, 3)
    }
}

final class UnitPathCacheTests: XCTestCase {

    /// Scaling a path parsed at unit scale must give the same shape as parsing at that scale.
    func testScaledUnitPathMatchesDirectParse() {
        let cache = PathCache()
        let scale: CGFloat = 0.37, offsetX: CGFloat = -12.5, offsetY: CGFloat = 40
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                for svg in BodyPathProvider.paths(gender: gender, side: side).flatMap(\.allPaths) {
                    let cached = cache.path(for: svg, scale: scale, offsetX: offsetX, offsetY: offsetY).boundingRect
                    let direct = PathBuilder.buildPath(from: svg, scale: scale, offsetX: offsetX, offsetY: offsetY).boundingRect
                    XCTAssertEqual(cached.minX, direct.minX, accuracy: 0.001)
                    XCTAssertEqual(cached.minY, direct.minY, accuracy: 0.001)
                    XCTAssertEqual(cached.width, direct.width, accuracy: 0.001)
                    XCTAssertEqual(cached.height, direct.height, accuracy: 0.001)
                }
            }
        }
    }

    func testEachPathIsParsedOnceAcrossSizes() {
        let cache = PathCache()
        let svg = "M 0 0 L 100 100 L 0 100 Z"
        _ = cache.path(for: svg, scale: 1, offsetX: 0, offsetY: 0)
        _ = cache.path(for: svg, scale: 2, offsetX: 5, offsetY: 5)
        XCTAssertEqual(cache.parsedCount, 1)
        XCTAssertEqual(cache.count, 2)
    }

    func testPreloadParsesWithoutSizing() {
        let cache = PathCache()
        let paths = BodyPathProvider.paths(gender: .female, side: .back).flatMap(\.allPaths)
        cache.preload(paths)
        XCTAssertEqual(cache.parsedCount, Set(paths).count)
        XCTAssertEqual(cache.count, 0)
    }
}
