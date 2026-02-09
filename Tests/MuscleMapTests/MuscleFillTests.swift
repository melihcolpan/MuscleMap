import XCTest
import SwiftUI
@testable import MuscleMap

final class MuscleFillTests: XCTestCase {

    // MARK: - MuscleFill Cases

    func testColorFill() {
        let fill = MuscleFill.color(.red)
        if case .color(let color) = fill {
            XCTAssertEqual(color, .red)
        } else {
            XCTFail("Expected .color case")
        }
    }

    func testLinearGradientFill() {
        let fill = MuscleFill.linearGradient(
            colors: [.red, .orange],
            startPoint: .top,
            endPoint: .bottom
        )
        if case .linearGradient(let colors, let start, let end) = fill {
            XCTAssertEqual(colors.count, 2)
            XCTAssertEqual(start, .top)
            XCTAssertEqual(end, .bottom)
        } else {
            XCTFail("Expected .linearGradient case")
        }
    }

    func testRadialGradientFill() {
        let fill = MuscleFill.radialGradient(
            colors: [.white, .blue],
            center: .center,
            startRadius: 0,
            endRadius: 40
        )
        if case .radialGradient(let colors, let center, let startR, let endR) = fill {
            XCTAssertEqual(colors.count, 2)
            XCTAssertEqual(center, .center)
            XCTAssertEqual(startR, 0)
            XCTAssertEqual(endR, 40)
        } else {
            XCTFail("Expected .radialGradient case")
        }
    }

    // MARK: - Equatable

    func testColorFillEquality() {
        let a = MuscleFill.color(.red)
        let b = MuscleFill.color(.red)
        XCTAssertEqual(a, b)
    }

    func testDifferentColorFillInequality() {
        let a = MuscleFill.color(.red)
        let b = MuscleFill.color(.blue)
        XCTAssertNotEqual(a, b)
    }

    func testLinearGradientEquality() {
        let a = MuscleFill.linearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        let b = MuscleFill.linearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        XCTAssertEqual(a, b)
    }

    func testDifferentFillTypesInequality() {
        let a = MuscleFill.color(.red)
        let b = MuscleFill.linearGradient(colors: [.red], startPoint: .top, endPoint: .bottom)
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Shading

    func testColorShadingDoesNotCrash() {
        let fill = MuscleFill.color(.red)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 200)
        let _ = fill.shading(in: rect)
    }

    func testLinearGradientShadingDoesNotCrash() {
        let fill = MuscleFill.linearGradient(
            colors: [.red, .orange, .yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        let rect = CGRect(x: 10, y: 20, width: 80, height: 160)
        let _ = fill.shading(in: rect)
    }

    func testRadialGradientShadingDoesNotCrash() {
        let fill = MuscleFill.radialGradient(
            colors: [.white, .blue, .purple],
            center: .center,
            startRadius: 0,
            endRadius: 50
        )
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let _ = fill.shading(in: rect)
    }

    func testShadingWithZeroSizeRect() {
        let fill = MuscleFill.linearGradient(
            colors: [.red, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        let rect = CGRect.zero
        let _ = fill.shading(in: rect)
    }

    // MARK: - MuscleHighlight Fill Integration

    func testHighlightWithColorFill() {
        let highlight = MuscleHighlight(muscle: .chest, color: .red)
        XCTAssertEqual(highlight.fill, .color(.red))
    }

    func testHighlightWithGradientFill() {
        let fill = MuscleFill.linearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom)
        let highlight = MuscleHighlight(muscle: .chest, fill: fill)
        XCTAssertEqual(highlight.fill, fill)
        XCTAssertEqual(highlight.color, .red) // First color of gradient
        XCTAssertEqual(highlight.opacity, 1.0)
    }

    func testHighlightWithRadialGradientFill() {
        let fill = MuscleFill.radialGradient(colors: [.white, .blue], center: .center, startRadius: 0, endRadius: 30)
        let highlight = MuscleHighlight(muscle: .biceps, fill: fill, opacity: 0.8)
        XCTAssertEqual(highlight.fill, fill)
        XCTAssertEqual(highlight.color, .white)
        XCTAssertEqual(highlight.opacity, 0.8)
    }

    func testHighlightEquatable() {
        let a = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.8)
        let b = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.8)
        XCTAssertEqual(a, b)
    }

    func testHighlightInequalityDifferentMuscle() {
        let a = MuscleHighlight(muscle: .chest, color: .red)
        let b = MuscleHighlight(muscle: .biceps, color: .red)
        XCTAssertNotEqual(a, b)
    }

    func testHighlightInequalityDifferentOpacity() {
        let a = MuscleHighlight(muscle: .chest, color: .red, opacity: 1.0)
        let b = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.5)
        XCTAssertNotEqual(a, b)
    }

    func testHighlightEmptyGradientColorsFallback() {
        let fill = MuscleFill.linearGradient(colors: [], startPoint: .top, endPoint: .bottom)
        let highlight = MuscleHighlight(muscle: .chest, fill: fill)
        XCTAssertEqual(highlight.color, .clear)
    }
}
