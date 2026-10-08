import XCTest
@testable import MuscleMap

final class MuscleTests: XCTestCase {

    func testAllMusclesCaseCount() {
        // 19 main + 3 new muscles + 14 sub-groups = 36
        XCTAssertEqual(Muscle.allCases.count, 36)
    }

    func testMuscleRawValues() {
        XCTAssertEqual(Muscle.abs.rawValue, "abs")
        XCTAssertEqual(Muscle.lowerBack.rawValue, "lower-back")
        XCTAssertEqual(Muscle.upperBack.rawValue, "upper-back")
        XCTAssertEqual(Muscle.chest.rawValue, "chest")
        XCTAssertEqual(Muscle.biceps.rawValue, "biceps")
    }

    func testMuscleDisplayNames() {
        XCTAssertEqual(Muscle.abs.displayName, "Abs")
        XCTAssertEqual(Muscle.lowerBack.displayName, "Lower Back")
        XCTAssertEqual(Muscle.upperBack.displayName, "Upper Back")
        XCTAssertEqual(Muscle.quadriceps.displayName, "Quadriceps")
    }

    func testMuscleIdentifiable() {
        XCTAssertEqual(Muscle.chest.id, "chest")
        XCTAssertEqual(Muscle.lowerBack.id, "lower-back")
    }

    func testMuscleFromRawValue() {
        XCTAssertEqual(Muscle(rawValue: "chest"), .chest)
        XCTAssertEqual(Muscle(rawValue: "lower-back"), .lowerBack)
        XCTAssertNil(Muscle(rawValue: "invalid"))
    }

    func testMuscleCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let muscle = Muscle.deltoids
        let data = try encoder.encode(muscle)
        let decoded = try decoder.decode(Muscle.self, from: data)
        XCTAssertEqual(decoded, muscle)
    }

    func testMuscleIsCosmeticPart() {
        XCTAssertTrue(Muscle.head.isCosmeticPart)
        XCTAssertFalse(Muscle.chest.isCosmeticPart)
        XCTAssertFalse(Muscle.abs.isCosmeticPart)
    }

    func testEveryMuscleHasDisplayName() {
        for muscle in Muscle.allCases {
            XCTAssertFalse(muscle.displayName.isEmpty, "\(muscle) has empty displayName")
        }
    }

    // MARK: - BodySlug

    func testBodySlugHairHasNoMuscle() {
        XCTAssertNil(BodySlug.hair.muscle)
    }

    func testBodySlugMuscleMapping() {
        XCTAssertEqual(BodySlug.chest.muscle, .chest)
        XCTAssertEqual(BodySlug.abs.muscle, .abs)
        XCTAssertEqual(BodySlug.lowerBack.muscle, .lowerBack)
    }

    // MARK: - MuscleSide, BodySide, BodyGender

    func testMuscleSideCases() {
        XCTAssertEqual(MuscleSide.allCases.count, 3)
    }

    func testBodySideCases() {
        XCTAssertEqual(BodySide.allCases.count, 2)
    }

    func testBodyGenderCases() {
        XCTAssertEqual(BodyGender.allCases.count, 2)
    }

    func testEnumsCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let side = MuscleSide.left
        let decoded = try decoder.decode(MuscleSide.self, from: try encoder.encode(side))
        XCTAssertEqual(decoded, side)

        let bodySide = BodySide.back
        let decodedSide = try decoder.decode(BodySide.self, from: try encoder.encode(bodySide))
        XCTAssertEqual(decodedSide, bodySide)

        let gender = BodyGender.female
        let decodedGender = try decoder.decode(BodyGender.self, from: try encoder.encode(gender))
        XCTAssertEqual(decodedGender, gender)
    }
}

final class MuscleDrawabilityTests: XCTestCase {

    func testRhomboidsAndRotatorCuffAreDrawnOnBackViewsOnly() {
        for muscle in [Muscle.rhomboids, .rotatorCuff] {
            XCTAssertTrue(muscle.isDrawable)
            for gender in BodyGender.allCases {
                XCTAssertTrue(muscle.isDrawable(gender: gender, side: .back), "\(muscle) \(gender) back")
                XCTAssertFalse(muscle.isDrawable(gender: gender, side: .front), "\(muscle) \(gender) front")
            }
        }
    }

    func testEveryMuscleIsDrawnSomewhere() {
        XCTAssertEqual(Muscle.allCases.filter { !$0.isDrawable }, [])
    }

    func testNewSubGroupArtwork() {
        for gender in BodyGender.allCases {
            XCTAssertTrue(Muscle.rearDeltoid.isDrawable(gender: gender, side: .back))
            XCTAssertTrue(Muscle.upperTrapezius.isDrawable(gender: gender, side: .back))
            XCTAssertTrue(Muscle.upperTrapezius.isDrawable(gender: gender, side: .front))
            XCTAssertTrue(Muscle.lowerTrapezius.isDrawable(gender: gender, side: .back))
            XCTAssertTrue(Muscle.ankles.isDrawable(gender: gender, side: .back))
        }
        // The hair covers the whole head on the female back view
        XCTAssertFalse(Muscle.head.isDrawable(gender: .female, side: .back))
    }

    func testDrawnMusclesAreReported() {
        XCTAssertTrue(Muscle.chest.isDrawable)
        XCTAssertTrue(Muscle.upperBack.isDrawable(gender: .male, side: .back))
        XCTAssertFalse(Muscle.upperBack.isDrawable(gender: .male, side: .front))
    }

    func testCarvedRegionsKeepPublicGroupingUnchanged() {
        XCTAssertNil(Muscle.rhomboids.parentGroup)
        XCTAssertNil(Muscle.rotatorCuff.parentGroup)
        XCTAssertFalse(Muscle.trapezius.subGroups.contains(.rhomboids))
        XCTAssertFalse(Muscle.upperBack.subGroups.contains(.rotatorCuff))
    }
}

final class CarvedRegionRenderingTests: XCTestCase {

    private let size = CGSize(width: 400, height: 800)

    private func renderer(_ highlights: [Muscle: MuscleHighlight] = [:], gender: BodyGender = .male) -> BodyRenderer {
        BodyRenderer(gender: gender, side: .back, highlights: highlights, style: .default, selectedMuscles: [])
    }

    /// Muscles hit along a horizontal line through the middle of `region`.
    /// (The rect's centre falls in the midline gap between the left and right pieces.)
    private func hits(across region: Muscle, _ r: BodyRenderer) -> Set<Muscle> {
        guard let rect = r.boundingRect(for: region, in: size) else { return [] }
        var result = Set<Muscle>()
        for x in stride(from: rect.minX, through: rect.maxX, by: 1) {
            if let hit = r.hitTest(at: CGPoint(x: x, y: rect.midY), in: size) { result.insert(hit.0) }
        }
        return result
    }

    func testRegionTapResolvesToHostInDefaultMode() {
        for gender in BodyGender.allCases {
            let r = renderer(gender: gender)
            for (region, host) in [(Muscle.rhomboids, Muscle.trapezius), (.rotatorCuff, .upperBack)] {
                let found = hits(across: region, r)
                XCTAssertTrue(found.contains(host), "\(region) \(gender): \(found)")
                XCTAssertFalse(found.contains(region), "\(region) \(gender): \(found)")
            }
        }
    }

    func testRegionTapResolvesToRegionWhenSubGroupsShown() {
        let r = BodyRenderer(gender: .male, side: .back, highlights: [:], style: .default, selectedMuscles: [], hideSubGroups: false)
        XCTAssertTrue(hits(across: .rhomboids, r).contains(.rhomboids))
        XCTAssertTrue(hits(across: .rotatorCuff, r).contains(.rotatorCuff))
    }

    func testHostBoundingRectIncludesRegion() {
        let r = renderer()
        let host = r.boundingRect(for: .trapezius, in: size)!
        let region = r.boundingRect(for: .rhomboids, in: size)!
        XCTAssertTrue(host.contains(region))
    }

    func testOverlayRegionIsNotDrawnUntilHighlighted() {
        XCTAssertTrue(Muscle.rhomboids.isOverlayRegion)
        XCTAssertFalse(Muscle.rotatorCuff.isOverlayRegion)
        // The trapezius artwork stays whole: rhomboids lie entirely inside it.
        let r = renderer()
        let trap = r.boundingRect(for: .trapezius, in: size)!
        let rh = r.boundingRect(for: .rhomboids, in: size)!
        XCTAssertTrue(trap.contains(rh))
    }
}
