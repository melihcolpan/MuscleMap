import XCTest
import SwiftUI
@testable import MuscleMap

final class AnimationTests: XCTestCase {

    // MARK: - BodyView Animation Modifier

    func testAnimatedModifierReturnsBodyView() {
        let view = BodyView(gender: .male, side: .front)
            .animated(duration: 0.5)
        // Should compile and create a BodyView
        XCTAssertNotNil(view)
    }

    func testAnimatedDefaultDuration() {
        let view = BodyView(gender: .male, side: .front)
            .animated()
        XCTAssertNotNil(view)
    }

    func testPulseSelectedModifier() {
        let view = BodyView(gender: .male, side: .front)
            .selected(.chest)
            .pulseSelected(speed: 2.0, range: 0.5...1.0)
        XCTAssertNotNil(view)
    }

    func testPulseSelectedDefaultParameters() {
        let view = BodyView(gender: .male, side: .front)
            .selected(.biceps)
            .pulseSelected()
        XCTAssertNotNil(view)
    }

    func testPulseWithoutSelectionStillCreatesView() {
        let view = BodyView(gender: .male, side: .front)
            .pulseSelected()
        XCTAssertNotNil(view)
    }

    // MARK: - BodyRenderer Pulse Factor

    func testRendererDefaultPulseFactor() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscle: nil
        )
        XCTAssertEqual(renderer.selectionPulseFactor, 1.0)
    }

    func testRendererCustomPulseFactor() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscle: .chest,
            selectionPulseFactor: 0.7
        )
        XCTAssertEqual(renderer.selectionPulseFactor, 0.7)
    }

    // MARK: - Gradient + Animation Combo

    func testGradientHighlightWithAnimation() {
        let view = BodyView(gender: .male, side: .front)
            .highlight(.chest, linearGradient: [.red, .orange])
            .animated(duration: 0.4)
        XCTAssertNotNil(view)
    }

    func testRadialGradientWithPulse() {
        let view = BodyView(gender: .male, side: .front)
            .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 40)
            .selected(.biceps)
            .pulseSelected(speed: 1.0, range: 0.7...1.0)
        XCTAssertNotNil(view)
    }

    // MARK: - Modifier Chaining

    func testAllModifiersCombined() {
        let view = BodyView(gender: .female, side: .back)
            .highlight(.gluteal, color: .pink)
            .highlight(.hamstring, linearGradient: [.red, .orange])
            .highlight(.upperBack, radialGradient: [.white, .purple])
            .bodyStyle(.neon)
            .selected(.gluteal)
            .animated(duration: 0.2)
            .pulseSelected(speed: 2.0, range: 0.4...1.0)
        XCTAssertNotNil(view)
    }

    // MARK: - MuscleHighlight Equatable (for animation diffing)

    func testHighlightEqualForAnimation() {
        let a = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.8)
        let b = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.8)
        XCTAssertEqual(a, b)
    }

    func testHighlightNotEqualDifferentColor() {
        let a = MuscleHighlight(muscle: .chest, color: .red)
        let b = MuscleHighlight(muscle: .chest, color: .blue)
        XCTAssertNotEqual(a, b)
    }

    func testHighlightNotEqualDifferentFillType() {
        let a = MuscleHighlight(muscle: .chest, color: .red)
        let b = MuscleHighlight(
            muscle: .chest,
            fill: .linearGradient(colors: [.red], startPoint: .top, endPoint: .bottom)
        )
        XCTAssertNotEqual(a, b)
    }
}
