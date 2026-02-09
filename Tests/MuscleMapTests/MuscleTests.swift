import XCTest
@testable import MuscleMap

final class MuscleTests: XCTestCase {

    func testAllMusclesCaseCount() {
        // 22 original + 4 new muscles + 10 sub-groups = 36
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
