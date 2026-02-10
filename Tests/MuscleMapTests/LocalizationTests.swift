import XCTest
@testable import MuscleMap

final class LocalizationTests: XCTestCase {

    func testAllMuscleDisplayNamesNotEmpty() {
        for muscle in Muscle.allCases {
            XCTAssertFalse(muscle.displayName.isEmpty, "\(muscle) has empty displayName")
        }
    }

    func testDisplayNameDoesNotReturnRawKey() {
        for muscle in Muscle.allCases {
            XCTAssertFalse(
                muscle.displayName.hasPrefix("muscle."),
                "\(muscle) displayName returned raw key: \(muscle.displayName)"
            )
        }
    }

    func testEnglishDisplayNamesMatchExpected() {
        XCTAssertEqual(Muscle.abs.displayName, "Abs")
        XCTAssertEqual(Muscle.chest.displayName, "Chest")
        XCTAssertEqual(Muscle.lowerBack.displayName, "Lower Back")
        XCTAssertEqual(Muscle.upperBack.displayName, "Upper Back")
        XCTAssertEqual(Muscle.quadriceps.displayName, "Quadriceps")
        XCTAssertEqual(Muscle.rotatorCuff.displayName, "Rotator Cuff")
        XCTAssertEqual(Muscle.hipFlexors.displayName, "Hip Flexors")
        XCTAssertEqual(Muscle.upperChest.displayName, "Upper Chest")
        XCTAssertEqual(Muscle.frontDeltoid.displayName, "Front Deltoid")
    }

    func testMuscleSideDisplayName() {
        XCTAssertEqual(MuscleSide.left.displayName, "Left")
        XCTAssertEqual(MuscleSide.right.displayName, "Right")
        XCTAssertEqual(MuscleSide.both.displayName, "Both")
    }

    func testBodySideDisplayName() {
        XCTAssertEqual(BodySide.front.displayName, "Front")
        XCTAssertEqual(BodySide.back.displayName, "Back")
    }

    func testBodyGenderDisplayName() {
        XCTAssertEqual(BodyGender.male.displayName, "Male")
        XCTAssertEqual(BodyGender.female.displayName, "Female")
    }
}
