import XCTest
@testable import MuscleMap

@MainActor
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

@MainActor
final class AccessibilityPerSideTests: XCTestCase {

    private let size = CGSize(width: 300, height: 600)

    private func items(_ gender: BodyGender = .male, _ side: BodySide = .front) -> [MuscleAccessibilityItem] {
        let overlay = BodyAccessibilityOverlay(
            gender: gender, side: side, highlights: [:], style: .default,
            selectedMuscles: [], size: size, onMuscleSelected: nil, onMuscleLongPressed: nil
        )
        let renderer = BodyRenderer(gender: gender, side: side, highlights: [:], style: .default, selectedMuscles: [])
        return overlay.visibleMuscles(renderer: renderer)
    }

    func testPairedMusclesGetOneElementPerSide() {
        let biceps = items().filter { $0.muscle == .biceps }
        XCTAssertEqual(biceps.map(\.side), [.left, .right])
        XCTAssertFalse(biceps[0].rect.intersects(biceps[1].rect))
        XCTAssertLessThan(biceps[0].rect.midX, biceps[1].rect.midX)
    }

    func testSidesOfAMuscleAreAdjacent() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let list = items(gender, side)
                for (index, item) in list.enumerated() where item.side == .left {
                    XCTAssertEqual(list[index + 1].muscle, item.muscle, "\(item.muscle) \(gender) \(side)")
                    XCTAssertEqual(list[index + 1].side, .right)
                }
            }
        }
    }

    func testIdentifiersAreUnique() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let ids = items(gender, side).map(\.id)
                XCTAssertEqual(ids.count, Set(ids).count)
            }
        }
    }

    func testLabels() {
        let left = MuscleAccessibilityItem(muscle: .biceps, side: .left, rect: .zero)
        XCTAssertEqual(left.label, "\(Muscle.biceps.displayName), \(MuscleSide.left.displayName)")
        let single = MuscleAccessibilityItem(muscle: .abs, side: .both, rect: .zero)
        XCTAssertEqual(single.label, Muscle.abs.displayName)
    }
}
