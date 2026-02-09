import XCTest
import SwiftUI
@testable import MuscleMap

final class PathBuilderTests: XCTestCase {

    func testBuildPathFromSimpleLine() {
        let path = PathBuilder.buildPath(
            from: "M 0 0 L 100 100",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testBuildPathWithScale() {
        let path = PathBuilder.buildPath(
            from: "M 0 0 L 100 100",
            scale: 2.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
        // The bounding box should be scaled
        let bounds = path.boundingRect
        XCTAssertEqual(bounds.maxX, 200, accuracy: 1)
        XCTAssertEqual(bounds.maxY, 200, accuracy: 1)
    }

    func testBuildPathWithOffset() {
        let path = PathBuilder.buildPath(
            from: "M 0 0 L 100 100",
            scale: 1.0,
            offsetX: 50,
            offsetY: 50
        )
        let bounds = path.boundingRect
        XCTAssertEqual(bounds.minX, 50, accuracy: 1)
        XCTAssertEqual(bounds.minY, 50, accuracy: 1)
    }

    func testBuildPathFromClosedTriangle() {
        let path = PathBuilder.buildPath(
            from: "M 0 0 L 100 0 L 50 100 Z",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
        // Should contain the triangle center
        XCTAssertTrue(path.contains(CGPoint(x: 50, y: 30)))
    }

    func testBuildPathFromRealBodyPath() {
        // Use a real SVG path from MaleFrontPaths (chest left)
        let chestPath = "M272.91 422.84c-18.95-17.19-22-57-12.64-78.79 5.57-12.99 26.54-24.37 39.97-25.87q20.36-2.26 37.02.75c9.74 1.76 16.13 15.64 18.41 25.04 3.99 16.48 3.23 31.38 1.67 48.06q-1.35 14.35-2.05 16.89c-6.52 23.5-38.08 29.23-58.28 24.53-9.12-2.12-17.24-4.38-24.1-10.61z"
        let path = PathBuilder.buildPath(
            from: chestPath,
            scale: 0.5,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testBuildPathFromCurveCommands() {
        let path = PathBuilder.buildPath(
            from: "M 10 80 C 40 10 65 10 95 80 S 150 150 180 80",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testBuildPathFromQuadratic() {
        let path = PathBuilder.buildPath(
            from: "M 10 80 Q 95 10 180 80 T 350 80",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertFalse(path.isEmpty)
    }

    func testBuildPathEmptyString() {
        let path = PathBuilder.buildPath(
            from: "",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0
        )
        XCTAssertTrue(path.isEmpty)
    }
}
