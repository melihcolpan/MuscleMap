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

    // MARK: - ColorInterpolation

    func testLinearInterpolation() {
        let interp = ColorInterpolation.linear
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
    }

    func testEaseInInterpolation() {
        let interp = ColorInterpolation.easeIn
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
        // Ease-in: at 0.5, should be less than 0.5 (slow start)
        XCTAssertLessThan(interp.apply(0.5), 0.5)
    }

    func testEaseOutInterpolation() {
        let interp = ColorInterpolation.easeOut
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
        // Ease-out: at 0.5, should be greater than 0.5 (fast start)
        XCTAssertGreaterThan(interp.apply(0.5), 0.5)
    }

    func testEaseInOutInterpolation() {
        let interp = ColorInterpolation.easeInOut
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
        // First half is slow (easeIn), so at 0.25 should be less than 0.25
        XCTAssertLessThan(interp.apply(0.25), 0.25)
        // Second half is fast, so at 0.75 should be greater than 0.75
        XCTAssertGreaterThan(interp.apply(0.75), 0.75)
    }

    func testStepInterpolation() {
        let interp = ColorInterpolation.step(count: 4)
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.24), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.26), 0.25, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.74), 0.5, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.76), 0.75, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
    }

    func testStepInterpolationZeroCount() {
        let interp = ColorInterpolation.step(count: 0)
        // Should fall back to identity
        XCTAssertEqual(interp.apply(0.5), 0.5, accuracy: 0.001)
    }

    func testCustomInterpolation() {
        let interp = ColorInterpolation.custom { t in t * t * t }
        XCTAssertEqual(interp.apply(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(interp.apply(0.5), 0.125, accuracy: 0.001)
        XCTAssertEqual(interp.apply(1.0), 1.0, accuracy: 0.001)
    }

    func testInterpolationClampsBelowZero() {
        let interp = ColorInterpolation.linear
        XCTAssertEqual(interp.apply(-0.5), 0.0, accuracy: 0.001)
    }

    func testInterpolationClampsAboveOne() {
        let interp = ColorInterpolation.linear
        XCTAssertEqual(interp.apply(1.5), 1.0, accuracy: 0.001)
    }

    func testColorInterpolationEquatable() {
        XCTAssertEqual(ColorInterpolation.linear, .linear)
        XCTAssertEqual(ColorInterpolation.easeIn, .easeIn)
        XCTAssertEqual(ColorInterpolation.easeOut, .easeOut)
        XCTAssertEqual(ColorInterpolation.easeInOut, .easeInOut)
        XCTAssertEqual(ColorInterpolation.step(count: 5), .step(count: 5))
        XCTAssertNotEqual(ColorInterpolation.step(count: 3), .step(count: 5))
        XCTAssertNotEqual(ColorInterpolation.linear, .easeIn)
    }

    func testCustomInterpolationNeverEqual() {
        let a = ColorInterpolation.custom { $0 }
        let b = ColorInterpolation.custom { $0 }
        XCTAssertNotEqual(a, b)
    }

    // MARK: - HeatmapColorScale with Interpolation

    func testColorScaleDefaultInterpolationIsLinear() {
        let scale = HeatmapColorScale(colors: [.red, .blue])
        XCTAssertEqual(scale.interpolation, .linear)
    }

    func testColorScaleWithEaseInInterpolation() {
        let scale = HeatmapColorScale(colors: [.red, .blue], interpolation: .easeIn)
        XCTAssertEqual(scale.interpolation, .easeIn)
        // Should not crash
        let _ = scale.color(for: 0.5)
    }

    func testWorkoutSteppedPreset() {
        let scale = HeatmapColorScale.workoutStepped
        XCTAssertEqual(scale.interpolation, .step(count: 5))
        XCTAssertEqual(scale.colors.count, 4)
    }

    func testThermalSmoothPreset() {
        let scale = HeatmapColorScale.thermalSmooth
        XCTAssertEqual(scale.interpolation, .easeInOut)
        XCTAssertEqual(scale.colors.count, 4)
    }

    // MARK: - HeatmapConfiguration

    func testDefaultConfiguration() {
        let config = HeatmapConfiguration.default
        XCTAssertEqual(config.interpolation, .linear)
        XCTAssertNil(config.threshold)
        XCTAssertFalse(config.isGradientFillEnabled)
        XCTAssertEqual(config.gradientDirection, .topToBottom)
        XCTAssertEqual(config.gradientLowIntensityFactor, 0.3, accuracy: 0.001)
    }

    func testConfigurationWithThreshold() {
        let config = HeatmapConfiguration(threshold: 0.2)
        XCTAssertEqual(config.threshold, 0.2)
    }

    func testConfigurationWithGradient() {
        let config = HeatmapConfiguration(
            isGradientFillEnabled: true,
            gradientDirection: .leftToRight,
            gradientLowIntensityFactor: 0.5
        )
        XCTAssertTrue(config.isGradientFillEnabled)
        XCTAssertEqual(config.gradientDirection, .leftToRight)
        XCTAssertEqual(config.gradientLowIntensityFactor, 0.5, accuracy: 0.001)
    }

    func testConfigurationEquatable() {
        let a = HeatmapConfiguration(threshold: 0.3)
        let b = HeatmapConfiguration(threshold: 0.3)
        XCTAssertEqual(a, b)

        let c = HeatmapConfiguration(threshold: 0.5)
        XCTAssertNotEqual(a, c)
    }

    // MARK: - GradientDirection

    func testGradientDirectionUnitPoints() {
        XCTAssertEqual(GradientDirection.topToBottom.startPoint, .top)
        XCTAssertEqual(GradientDirection.topToBottom.endPoint, .bottom)
        XCTAssertEqual(GradientDirection.bottomToTop.startPoint, .bottom)
        XCTAssertEqual(GradientDirection.bottomToTop.endPoint, .top)
        XCTAssertEqual(GradientDirection.leftToRight.startPoint, .leading)
        XCTAssertEqual(GradientDirection.leftToRight.endPoint, .trailing)
        XCTAssertEqual(GradientDirection.rightToLeft.startPoint, .trailing)
        XCTAssertEqual(GradientDirection.rightToLeft.endPoint, .leading)
    }
}
