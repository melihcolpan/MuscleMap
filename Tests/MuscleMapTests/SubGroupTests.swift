import XCTest
@testable import MuscleMap

final class SubGroupTests: XCTestCase {

    // MARK: - Sub-Group Relationships

    func testChestSubGroups() {
        XCTAssertEqual(Muscle.chest.subGroups, [.upperChest, .lowerChest])
    }

    func testQuadricepsSubGroups() {
        XCTAssertEqual(Muscle.quadriceps.subGroups, [.innerQuad, .outerQuad, .hipFlexors])
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

    func testObliquesSubGroups() {
        XCTAssertEqual(Muscle.obliques.subGroups, [.serratus])
    }

    func testFeetSubGroups() {
        XCTAssertEqual(Muscle.feet.subGroups, [.ankles])
    }

    func testHamstringSubGroups() {
        XCTAssertEqual(Muscle.hamstring.subGroups, [.adductors])
    }

    func testHeadSubGroups() {
        XCTAssertEqual(Muscle.head.subGroups, [.neck])
    }

    func testNonParentHasNoSubGroups() {
        XCTAssertTrue(Muscle.biceps.subGroups.isEmpty)
        XCTAssertTrue(Muscle.calves.subGroups.isEmpty)
        XCTAssertTrue(Muscle.forearm.subGroups.isEmpty)
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

    func testSerratusParent() {
        XCTAssertEqual(Muscle.serratus.parentGroup, .obliques)
    }

    func testHipFlexorsParent() {
        XCTAssertEqual(Muscle.hipFlexors.parentGroup, .quadriceps)
    }

    func testAnklesParent() {
        XCTAssertEqual(Muscle.ankles.parentGroup, .feet)
    }

    func testAdductorsParent() {
        XCTAssertEqual(Muscle.adductors.parentGroup, .hamstring)
    }

    func testNeckParent() {
        XCTAssertEqual(Muscle.neck.parentGroup, .head)
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
        XCTAssertTrue(Muscle.hipFlexors.isSubGroup)
        XCTAssertTrue(Muscle.upperAbs.isSubGroup)
        XCTAssertTrue(Muscle.lowerAbs.isSubGroup)
        XCTAssertTrue(Muscle.frontDeltoid.isSubGroup)
        XCTAssertTrue(Muscle.rearDeltoid.isSubGroup)
        XCTAssertTrue(Muscle.upperTrapezius.isSubGroup)
        XCTAssertTrue(Muscle.lowerTrapezius.isSubGroup)
        XCTAssertTrue(Muscle.ankles.isSubGroup)
        XCTAssertTrue(Muscle.adductors.isSubGroup)
        XCTAssertTrue(Muscle.neck.isSubGroup)
    }

    func testIsSubGroupFalse() {
        XCTAssertFalse(Muscle.chest.isSubGroup)
        XCTAssertFalse(Muscle.abs.isSubGroup)
        XCTAssertFalse(Muscle.quadriceps.isSubGroup)
        XCTAssertFalse(Muscle.deltoids.isSubGroup)
        XCTAssertFalse(Muscle.trapezius.isSubGroup)
        XCTAssertFalse(Muscle.rotatorCuff.isSubGroup)
        XCTAssertTrue(Muscle.serratus.isSubGroup)
    }

    // MARK: - New Muscles

    func testNewMuscleDisplayNames() {
        XCTAssertEqual(Muscle.rotatorCuff.displayName, "Rotator Cuff")
        XCTAssertEqual(Muscle.serratus.displayName, "Serratus")
        XCTAssertEqual(Muscle.rhomboids.displayName, "Rhomboids")
    }

    func testNewMuscleRawValues() {
        XCTAssertEqual(Muscle.rotatorCuff.rawValue, "rotator-cuff")
        XCTAssertEqual(Muscle.serratus.rawValue, "serratus")
        XCTAssertEqual(Muscle.rhomboids.rawValue, "rhomboids")
    }

    func testNewMusclesAreNotCosmetic() {
        XCTAssertFalse(Muscle.rotatorCuff.isCosmeticPart)
        XCTAssertFalse(Muscle.serratus.isCosmeticPart)
        XCTAssertFalse(Muscle.rhomboids.isCosmeticPart)
    }

    func testSubGroupDisplayNames() {
        XCTAssertEqual(Muscle.ankles.displayName, "Ankles")
        XCTAssertEqual(Muscle.adductors.displayName, "Adductors")
        XCTAssertEqual(Muscle.neck.displayName, "Neck")
        XCTAssertEqual(Muscle.hipFlexors.displayName, "Hip Flexors")
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
        // Drawn from the deltoid and trapezius outlines, around the rhomboid band
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
        // Drawn from the deltoid and trapezius outlines, around the rhomboid band
        XCTAssertTrue(slugs.contains(.rearDeltoid))
        XCTAssertTrue(slugs.contains(.upperTrapezius))
        XCTAssertTrue(slugs.contains(.lowerTrapezius))
    }

    // MARK: - hideSubGroups

    func testHideSubGroupsFiltersRendering() {
        // When hideSubGroups is true (default), sub-group body parts should be skipped in render.
        // We verify by checking hitTest: sub-group paths should not be hittable.
        let paths = BodyPathProvider.paths(gender: .male, side: .front)
        let subGroupSlugs = paths.compactMap { part -> BodySlug? in
            guard let muscle = part.slug.muscle, muscle.isSubGroup else { return nil }
            return part.slug
        }
        // Ensure there are sub-group paths in male front data
        XCTAssertFalse(subGroupSlugs.isEmpty, "Expected sub-group paths in male front data")

        // With hideSubGroups=true, renderer should skip sub-groups
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [.upperChest: MuscleHighlight(muscle: .upperChest, color: .red, opacity: 1.0)],
            style: .default,
            selectedMuscles: [],
            hideSubGroups: true
        )

        // The renderer with hideSubGroups=true should not return sub-group muscles from hitTest
        // We can't easily test render() output, but hitTest uses the same filter
        let size = CGSize(width: 300, height: 600)
        // Scan the entire area — no sub-group should be returned
        for x in stride(from: 0.0, through: 300.0, by: 5.0) {
            for y in stride(from: 0.0, through: 600.0, by: 5.0) {
                if let (muscle, _) = renderer.hitTest(at: CGPoint(x: x, y: y), in: size) {
                    XCTAssertFalse(muscle.isSubGroup, "Sub-group \(muscle) should not be hittable when hideSubGroups is true")
                }
            }
        }
    }

    func testShowSubGroupsAllowsHitTest() {
        // When hideSubGroups is false, sub-group muscles should be hittable.
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [.upperChest: MuscleHighlight(muscle: .upperChest, color: .red, opacity: 1.0)],
            style: .default,
            selectedMuscles: [],
            hideSubGroups: false
        )

        let size = CGSize(width: 300, height: 600)
        var foundSubGroup = false
        for x in stride(from: 0.0, through: 300.0, by: 5.0) {
            for y in stride(from: 0.0, through: 600.0, by: 5.0) {
                if let (muscle, _) = renderer.hitTest(at: CGPoint(x: x, y: y), in: size) {
                    if muscle.isSubGroup {
                        foundSubGroup = true
                        break
                    }
                }
            }
            if foundSubGroup { break }
        }
        XCTAssertTrue(foundSubGroup, "Expected at least one sub-group to be hittable when hideSubGroups is false")
    }

    func testDefaultRendererHidesSubGroups() {
        // Default BodyRenderer should hide sub-groups
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: []
        )

        let size = CGSize(width: 300, height: 600)
        for x in stride(from: 0.0, through: 300.0, by: 5.0) {
            for y in stride(from: 0.0, through: 600.0, by: 5.0) {
                if let (muscle, _) = renderer.hitTest(at: CGPoint(x: x, y: y), in: size) {
                    XCTAssertFalse(muscle.isSubGroup, "Sub-group \(muscle) should not be hittable by default")
                }
            }
        }
    }

    // MARK: - Always-Visible Sub-Groups

    func testAlwaysVisibleSubGroupProperty() {
        XCTAssertTrue(Muscle.ankles.isAlwaysVisibleSubGroup)
        XCTAssertTrue(Muscle.adductors.isAlwaysVisibleSubGroup)
        XCTAssertTrue(Muscle.neck.isAlwaysVisibleSubGroup)
        XCTAssertFalse(Muscle.upperChest.isAlwaysVisibleSubGroup)
        XCTAssertFalse(Muscle.hipFlexors.isAlwaysVisibleSubGroup)
        XCTAssertFalse(Muscle.serratus.isAlwaysVisibleSubGroup)
        XCTAssertFalse(Muscle.chest.isAlwaysVisibleSubGroup)
    }

    func testAlwaysVisibleSubGroupReturnsParentWhenHidden() {
        // When hideSubGroups=true, tapping ankles should return feet
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: [],
            hideSubGroups: true
        )

        let size = CGSize(width: 300, height: 600)
        var hitResults = Set<Muscle>()
        for x in stride(from: 0.0, through: 300.0, by: 3.0) {
            for y in stride(from: 0.0, through: 600.0, by: 3.0) {
                if let (muscle, _) = renderer.hitTest(at: CGPoint(x: x, y: y), in: size) {
                    hitResults.insert(muscle)
                }
            }
        }
        // ankles/adductors/neck should NOT appear — their parents should
        XCTAssertFalse(hitResults.contains(.ankles), "ankles should resolve to feet")
        XCTAssertFalse(hitResults.contains(.adductors), "adductors should resolve to hamstring")
        XCTAssertFalse(hitResults.contains(.neck), "neck should resolve to head")
    }

    func testAlwaysVisibleSubGroupReturnsSelfWhenShown() {
        // When hideSubGroups=false, tapping ankles should return ankles
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: [],
            hideSubGroups: false
        )

        let size = CGSize(width: 300, height: 600)
        var hitResults = Set<Muscle>()
        for x in stride(from: 0.0, through: 300.0, by: 3.0) {
            for y in stride(from: 0.0, through: 600.0, by: 3.0) {
                if let (muscle, _) = renderer.hitTest(at: CGPoint(x: x, y: y), in: size) {
                    hitResults.insert(muscle)
                }
            }
        }
        // In showSubGroups mode, always-visible sub-groups return themselves
        XCTAssertTrue(hitResults.contains(.ankles), "ankles should be directly hittable in showSubGroups mode")
        XCTAssertTrue(hitResults.contains(.adductors), "adductors should be directly hittable in showSubGroups mode")
        XCTAssertTrue(hitResults.contains(.neck), "neck should be directly hittable in showSubGroups mode")
    }

    // MARK: - Case Count

    func testMuscleAllCasesCount() {
        // 19 main + 3 new muscles + 14 sub-groups = 36
        XCTAssertEqual(Muscle.allCases.count, 36)
    }
}

final class SubGroupShapeTests: XCTestCase {

    /// Every sub-group shape is cut from its parent's artwork, so it must lie inside the parent.
    func testSubGroupsLieInsideTheirParent() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let parts = BodyPathProvider.paths(gender: gender, side: side)
                for part in parts {
                    guard let muscle = part.slug.muscle, let parent = muscle.parentGroup,
                          !muscle.isAlwaysVisibleSubGroup else { continue }
                    let parentRect = parts.filter { $0.slug.muscle == parent }
                        .flatMap(\.allPaths)
                        .map { PathBuilder.buildPath(from: $0, scale: 1, offsetX: 0, offsetY: 0).boundingRect }
                        .reduce(CGRect.null) { $0.union($1) }
                    for svg in part.allPaths {
                        let rect = PathBuilder.buildPath(from: svg, scale: 1, offsetX: 0, offsetY: 0).boundingRect
                        XCTAssertTrue(parentRect.insetBy(dx: -1, dy: -1).contains(rect), "\(muscle) outside \(parent) on \(gender) \(side)")
                    }
                }
            }
        }
    }
}
