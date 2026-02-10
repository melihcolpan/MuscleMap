import XCTest
@testable import MuscleMap

final class AccessibilityTests: XCTestCase {

    func testAccessibilityOverlayCreatesForAllCombinations() {
        let size = CGSize(width: 300, height: 600)
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let overlay = BodyAccessibilityOverlay(
                    gender: gender,
                    side: side,
                    highlights: [:],
                    style: .default,
                    selectedMuscles: [],
                    size: size,
                    onMuscleSelected: nil,
                    onMuscleLongPressed: nil
                )
                // Verify the overlay can be created without crashing
                XCTAssertNotNil(overlay)
            }
        }
    }

    func testVisibleMusclesExcludesCosmeticParts() {
        let bodyParts = BodyPathProvider.paths(gender: .male, side: .front)
        var visibleMuscles: [Muscle] = []

        for bodyPart in bodyParts {
            guard let muscle = bodyPart.slug.muscle,
                  !muscle.isCosmeticPart else { continue }
            if !visibleMuscles.contains(muscle) {
                visibleMuscles.append(muscle)
            }
        }

        XCTAssertFalse(visibleMuscles.contains(.head), "Head should be excluded from accessibility")
    }

    func testBoundingRectExistsForVisibleMuscles() {
        let size = CGSize(width: 300, height: 600)
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: []
        )

        let bodyParts = BodyPathProvider.paths(gender: .male, side: .front)
        var seen = Set<Muscle>()

        for bodyPart in bodyParts {
            guard let muscle = bodyPart.slug.muscle,
                  !muscle.isCosmeticPart,
                  !seen.contains(muscle) else { continue }
            seen.insert(muscle)

            let rect = renderer.boundingRect(for: muscle, in: size)
            XCTAssertNotNil(rect, "\(muscle) should have a bounding rect")
            if let rect = rect {
                XCTAssertFalse(rect.isEmpty, "\(muscle) bounding rect should not be empty")
            }
        }
    }

    func testBoundingRectForAllGenderSideCombinations() {
        let size = CGSize(width: 300, height: 600)

        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let renderer = BodyRenderer(
                    gender: gender,
                    side: side,
                    highlights: [:],
                    style: .default,
                    selectedMuscles: []
                )

                let bodyParts = BodyPathProvider.paths(gender: gender, side: side)
                var seen = Set<Muscle>()

                for bodyPart in bodyParts {
                    guard let muscle = bodyPart.slug.muscle,
                          !muscle.isCosmeticPart,
                          !seen.contains(muscle) else { continue }
                    seen.insert(muscle)

                    let rect = renderer.boundingRect(for: muscle, in: size)
                    XCTAssertNotNil(rect, "\(muscle) should have a bounding rect for \(gender)/\(side)")
                }
            }
        }
    }
}
