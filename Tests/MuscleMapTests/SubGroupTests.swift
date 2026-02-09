import XCTest
@testable import MuscleMap

final class SubGroupTests: XCTestCase {

    // MARK: - Sub-Group Relationships

    func testChestSubGroups() {
        XCTAssertEqual(Muscle.chest.subGroups, [.upperChest, .lowerChest])
    }

    func testQuadricepsSubGroups() {
        XCTAssertEqual(Muscle.quadriceps.subGroups, [.innerQuad, .outerQuad])
    }

    func testAbsSubGroups() {
        XCTAssertEqual(Muscle.abs.subGroups, [.upperAbs, .lowerAbs])
    }

    func testDeltoidsSubGroups() {
        XCTAssertEqual(Muscle.deltoids.subGroups, [.frontDeltoid, .rearDeltoid])
    }

    func testTrapeziusSubGroups() {
        XCTAssertEqual(Muscle.trapezius.subGroups, [.upperTrapezius, .lowerTrapezius])
    }

    func testNonParentHasNoSubGroups() {
        XCTAssertTrue(Muscle.biceps.subGroups.isEmpty)
        XCTAssertTrue(Muscle.calves.subGroups.isEmpty)
        XCTAssertTrue(Muscle.forearm.subGroups.isEmpty)
        XCTAssertTrue(Muscle.hamstring.subGroups.isEmpty)
    }

    // MARK: - Parent Group

    func testUpperChestParent() {
        XCTAssertEqual(Muscle.upperChest.parentGroup, .chest)
    }

    func testLowerChestParent() {
        XCTAssertEqual(Muscle.lowerChest.parentGroup, .chest)
    }

    func testInnerQuadParent() {
        XCTAssertEqual(Muscle.innerQuad.parentGroup, .quadriceps)
    }

    func testOuterQuadParent() {
        XCTAssertEqual(Muscle.outerQuad.parentGroup, .quadriceps)
    }

    func testUpperAbsParent() {
        XCTAssertEqual(Muscle.upperAbs.parentGroup, .abs)
    }

    func testLowerAbsParent() {
        XCTAssertEqual(Muscle.lowerAbs.parentGroup, .abs)
    }

    func testFrontDeltoidParent() {
        XCTAssertEqual(Muscle.frontDeltoid.parentGroup, .deltoids)
    }

    func testRearDeltoidParent() {
        XCTAssertEqual(Muscle.rearDeltoid.parentGroup, .deltoids)
    }

    func testUpperTrapeziusParent() {
        XCTAssertEqual(Muscle.upperTrapezius.parentGroup, .trapezius)
    }

    func testLowerTrapeziusParent() {
        XCTAssertEqual(Muscle.lowerTrapezius.parentGroup, .trapezius)
    }

    func testNonSubGroupHasNoParent() {
        XCTAssertNil(Muscle.chest.parentGroup)
        XCTAssertNil(Muscle.biceps.parentGroup)
        XCTAssertNil(Muscle.gluteal.parentGroup)
        XCTAssertNil(Muscle.rotatorCuff.parentGroup)
    }

    // MARK: - isSubGroup

    func testIsSubGroupTrue() {
        XCTAssertTrue(Muscle.upperChest.isSubGroup)
        XCTAssertTrue(Muscle.lowerChest.isSubGroup)
        XCTAssertTrue(Muscle.innerQuad.isSubGroup)
        XCTAssertTrue(Muscle.outerQuad.isSubGroup)
        XCTAssertTrue(Muscle.upperAbs.isSubGroup)
        XCTAssertTrue(Muscle.lowerAbs.isSubGroup)
        XCTAssertTrue(Muscle.frontDeltoid.isSubGroup)
        XCTAssertTrue(Muscle.rearDeltoid.isSubGroup)
        XCTAssertTrue(Muscle.upperTrapezius.isSubGroup)
        XCTAssertTrue(Muscle.lowerTrapezius.isSubGroup)
    }

    func testIsSubGroupFalse() {
        XCTAssertFalse(Muscle.chest.isSubGroup)
        XCTAssertFalse(Muscle.abs.isSubGroup)
        XCTAssertFalse(Muscle.quadriceps.isSubGroup)
        XCTAssertFalse(Muscle.deltoids.isSubGroup)
        XCTAssertFalse(Muscle.trapezius.isSubGroup)
        XCTAssertFalse(Muscle.rotatorCuff.isSubGroup)
        XCTAssertFalse(Muscle.serratus.isSubGroup)
    }

    // MARK: - New Muscles

    func testNewMuscleDisplayNames() {
        XCTAssertEqual(Muscle.rotatorCuff.displayName, "Rotator Cuff")
        XCTAssertEqual(Muscle.hipFlexors.displayName, "Hip Flexors")
        XCTAssertEqual(Muscle.serratus.displayName, "Serratus")
        XCTAssertEqual(Muscle.rhomboids.displayName, "Rhomboids")
    }

    func testNewMuscleRawValues() {
        XCTAssertEqual(Muscle.rotatorCuff.rawValue, "rotator-cuff")
        XCTAssertEqual(Muscle.hipFlexors.rawValue, "hip-flexors")
        XCTAssertEqual(Muscle.serratus.rawValue, "serratus")
        XCTAssertEqual(Muscle.rhomboids.rawValue, "rhomboids")
    }

    func testNewMusclesAreNotCosmetic() {
        XCTAssertFalse(Muscle.rotatorCuff.isCosmeticPart)
        XCTAssertFalse(Muscle.hipFlexors.isCosmeticPart)
        XCTAssertFalse(Muscle.serratus.isCosmeticPart)
        XCTAssertFalse(Muscle.rhomboids.isCosmeticPart)
    }

    func testSubGroupDisplayNames() {
        XCTAssertEqual(Muscle.upperChest.displayName, "Upper Chest")
        XCTAssertEqual(Muscle.lowerChest.displayName, "Lower Chest")
        XCTAssertEqual(Muscle.innerQuad.displayName, "Inner Quad")
        XCTAssertEqual(Muscle.outerQuad.displayName, "Outer Quad")
        XCTAssertEqual(Muscle.upperAbs.displayName, "Upper Abs")
        XCTAssertEqual(Muscle.lowerAbs.displayName, "Lower Abs")
        XCTAssertEqual(Muscle.frontDeltoid.displayName, "Front Deltoid")
        XCTAssertEqual(Muscle.rearDeltoid.displayName, "Rear Deltoid")
        XCTAssertEqual(Muscle.upperTrapezius.displayName, "Upper Trapezius")
        XCTAssertEqual(Muscle.lowerTrapezius.displayName, "Lower Trapezius")
    }

    // MARK: - BodySlug Mapping

    func testNewBodySlugMapping() {
        XCTAssertEqual(BodySlug.rotatorCuff.muscle, .rotatorCuff)
        XCTAssertEqual(BodySlug.hipFlexors.muscle, .hipFlexors)
        XCTAssertEqual(BodySlug.serratus.muscle, .serratus)
        XCTAssertEqual(BodySlug.rhomboids.muscle, .rhomboids)
        XCTAssertEqual(BodySlug.upperChest.muscle, .upperChest)
        XCTAssertEqual(BodySlug.lowerChest.muscle, .lowerChest)
        XCTAssertEqual(BodySlug.innerQuad.muscle, .innerQuad)
        XCTAssertEqual(BodySlug.outerQuad.muscle, .outerQuad)
    }

    // MARK: - Path Data Existence

    func testNewMusclePathsExistInMaleFront() {
        let paths = BodyPathProvider.paths(gender: .male, side: .front)
        let slugs = paths.map { $0.slug }
        XCTAssertTrue(slugs.contains(.serratus))
        XCTAssertTrue(slugs.contains(.hipFlexors))
        XCTAssertTrue(slugs.contains(.upperChest))
        XCTAssertTrue(slugs.contains(.lowerChest))
        XCTAssertTrue(slugs.contains(.innerQuad))
        XCTAssertTrue(slugs.contains(.outerQuad))
        XCTAssertTrue(slugs.contains(.upperAbs))
        XCTAssertTrue(slugs.contains(.lowerAbs))
        XCTAssertTrue(slugs.contains(.frontDeltoid))
    }

    func testNewMusclePathsExistInMaleBack() {
        let paths = BodyPathProvider.paths(gender: .male, side: .back)
        let slugs = paths.map { $0.slug }
        XCTAssertTrue(slugs.contains(.rotatorCuff))
        XCTAssertTrue(slugs.contains(.rhomboids))
        XCTAssertTrue(slugs.contains(.rearDeltoid))
        XCTAssertTrue(slugs.contains(.upperTrapezius))
        XCTAssertTrue(slugs.contains(.lowerTrapezius))
    }

    func testNewMusclePathsExistInFemaleFront() {
        let paths = BodyPathProvider.paths(gender: .female, side: .front)
        let slugs = paths.map { $0.slug }
        XCTAssertTrue(slugs.contains(.serratus))
        XCTAssertTrue(slugs.contains(.hipFlexors))
        XCTAssertTrue(slugs.contains(.upperChest))
        XCTAssertTrue(slugs.contains(.lowerChest))
        XCTAssertTrue(slugs.contains(.frontDeltoid))
    }

    func testNewMusclePathsExistInFemaleBack() {
        let paths = BodyPathProvider.paths(gender: .female, side: .back)
        let slugs = paths.map { $0.slug }
        XCTAssertTrue(slugs.contains(.rotatorCuff))
        XCTAssertTrue(slugs.contains(.rhomboids))
        XCTAssertTrue(slugs.contains(.rearDeltoid))
        XCTAssertTrue(slugs.contains(.upperTrapezius))
        XCTAssertTrue(slugs.contains(.lowerTrapezius))
    }

    // MARK: - Case Count

    func testMuscleAllCasesCount() {
        // 22 original + 4 new muscles + 10 sub-groups = 36
        XCTAssertEqual(Muscle.allCases.count, 36)
    }
}
