import XCTest
import SwiftUI
@testable import MuscleMap

final class HeatmapTests: XCTestCase {

    // MARK: - MuscleIntensity

    func testMuscleIntensityClamping() {
        let overMax = MuscleIntensity(muscle: .chest, intensity: 1.5)
        XCTAssertEqual(overMax.intensity, 1.0)

        let underMin = MuscleIntensity(muscle: .chest, intensity: -0.5)
        XCTAssertEqual(underMin.intensity, 0.0)

        let normal = MuscleIntensity(muscle: .chest, intensity: 0.5)
        XCTAssertEqual(normal.intensity, 0.5)
    }

    func testMuscleIntensityDefaults() {
        let intensity = MuscleIntensity(muscle: .abs, intensity: 0.7)
        XCTAssertEqual(intensity.side, .both)
        XCTAssertNil(intensity.color)
    }

    func testMuscleIntensityCustomColor() {
        let intensity = MuscleIntensity(muscle: .abs, intensity: 0.5, color: .blue)
        XCTAssertNotNil(intensity.color)
    }

    func testMuscleIntensityCustomSide() {
        let intensity = MuscleIntensity(muscle: .biceps, intensity: 0.8, side: .left)
        XCTAssertEqual(intensity.side, .left)
    }

    // MARK: - MuscleHighlight

    func testMuscleHighlightDefaultOpacity() {
        let highlight = MuscleHighlight(muscle: .chest, color: .red)
        XCTAssertEqual(highlight.opacity, 1.0)
    }

    func testMuscleHighlightCustomOpacity() {
        let highlight = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.5)
        XCTAssertEqual(highlight.opacity, 0.5)
    }

    func testMuscleHighlightDefaultFillIsColor() {
        let highlight = MuscleHighlight(muscle: .chest, color: .red)
        XCTAssertEqual(highlight.fill, .color(.red))
    }

    func testMuscleHighlightGradientFill() {
        let fill = MuscleFill.linearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        let highlight = MuscleHighlight(muscle: .chest, fill: fill, opacity: 0.7)
        XCTAssertEqual(highlight.fill, fill)
        XCTAssertEqual(highlight.opacity, 0.7)
        XCTAssertEqual(highlight.color, .red) // fallback to first color
    }

    func testMuscleHighlightEquatable() {
        let a = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.5)
        let b = MuscleHighlight(muscle: .chest, color: .red, opacity: 0.5)
        XCTAssertEqual(a, b)
    }

    func testMuscleHighlightNotEqual() {
        let a = MuscleHighlight(muscle: .chest, color: .red)
        let b = MuscleHighlight(muscle: .biceps, color: .red)
        XCTAssertNotEqual(a, b)
    }

    // MARK: - HeatmapColorScale

    func testColorScaleEmptyColors() {
        let scale = HeatmapColorScale(colors: [])
        // Should return gray for empty
        let _ = scale.color(for: 0.5) // Should not crash
    }

    func testColorScaleSingleColor() {
        let scale = HeatmapColorScale(colors: [.red])
        let _ = scale.color(for: 0.5) // Should return the single color
    }

    func testColorScaleEdgeValues() {
        let scale = HeatmapColorScale.workout
        let _ = scale.color(for: 0.0) // Min
        let _ = scale.color(for: 1.0) // Max
        let _ = scale.color(for: 0.5) // Mid
    }

    func testColorScaleClampsBelowZero() {
        let scale = HeatmapColorScale.workout
        let _ = scale.color(for: -0.5) // Should not crash, clamp to 0
    }

    func testColorScaleClampsAboveOne() {
        let scale = HeatmapColorScale.workout
        let _ = scale.color(for: 1.5) // Should not crash, clamp to 1
    }

    func testPresetScalesExist() {
        XCTAssertFalse(HeatmapColorScale.workout.colors.isEmpty)
        XCTAssertFalse(HeatmapColorScale.thermal.colors.isEmpty)
        XCTAssertFalse(HeatmapColorScale.medical.colors.isEmpty)
        XCTAssertFalse(HeatmapColorScale.monochrome.colors.isEmpty)
    }

    func testWorkoutScaleHasFourColors() {
        XCTAssertEqual(HeatmapColorScale.workout.colors.count, 4)
    }

    func testThermalScaleHasFourColors() {
        XCTAssertEqual(HeatmapColorScale.thermal.colors.count, 4)
    }

    func testMedicalScaleHasThreeColors() {
        XCTAssertEqual(HeatmapColorScale.medical.colors.count, 3)
    }

    func testMonochromeScaleHasTwoColors() {
        XCTAssertEqual(HeatmapColorScale.monochrome.colors.count, 2)
    }
}
