import XCTest
@testable import MuscleMap

final class BodyPathDataTests: XCTestCase {

    // MARK: - BodyPartPathData

    func testBodyPartPathDataAllPaths() {
        let data = BodyPartPathData(
            slug: .chest,
            common: ["common1"],
            left: ["left1", "left2"],
            right: ["right1"]
        )
        XCTAssertEqual(data.allPaths.count, 4)
        XCTAssertEqual(data.allPaths, ["common1", "left1", "left2", "right1"])
    }

    func testBodyPartPathDataDefaults() {
        let data = BodyPartPathData(slug: .abs, left: ["path1"])
        XCTAssertTrue(data.common.isEmpty)
        XCTAssertEqual(data.left.count, 1)
        XCTAssertTrue(data.right.isEmpty)
    }

    // MARK: - BodyPathProvider

    func testMaleFrontPathsNotEmpty() {
        let paths = BodyPathProvider.paths(gender: .male, side: .front)
        XCTAssertGreaterThan(paths.count, 0, "Male front should have body parts")
    }

    func testMaleBackPathsNotEmpty() {
        let paths = BodyPathProvider.paths(gender: .male, side: .back)
        XCTAssertGreaterThan(paths.count, 0, "Male back should have body parts")
    }

    func testFemaleFrontPathsNotEmpty() {
        let paths = BodyPathProvider.paths(gender: .female, side: .front)
        XCTAssertGreaterThan(paths.count, 0, "Female front should have body parts")
    }

    func testFemaleBackPathsNotEmpty() {
        let paths = BodyPathProvider.paths(gender: .female, side: .back)
        XCTAssertGreaterThan(paths.count, 0, "Female back should have body parts")
    }

    func testAllPathsHaveNonEmptyData() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let paths = BodyPathProvider.paths(gender: gender, side: side)
                for part in paths {
                    XCTAssertFalse(
                        part.allPaths.isEmpty,
                        "\(gender) \(side) \(part.slug) has no SVG paths"
                    )
                    for pathStr in part.allPaths {
                        XCTAssertFalse(
                            pathStr.isEmpty,
                            "\(gender) \(side) \(part.slug) has empty path string"
                        )
                    }
                }
            }
        }
    }

    func testAllPathsAreParseable() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let paths = BodyPathProvider.paths(gender: gender, side: side)
                for part in paths {
                    for pathStr in part.allPaths {
                        let commands = SVGPathParser.parse(pathStr)
                        XCTAssertGreaterThan(
                            commands.count, 0,
                            "\(gender) \(side) \(part.slug): path is not parseable"
                        )
                    }
                }
            }
        }
    }

    // MARK: - BodyViewBox

    func testViewBoxDimensions() {
        let maleFront = BodyPathProvider.viewBox(gender: .male, side: .front)
        XCTAssertGreaterThan(maleFront.size.width, 0)
        XCTAssertGreaterThan(maleFront.size.height, 0)

        let femaleBack = BodyPathProvider.viewBox(gender: .female, side: .back)
        XCTAssertGreaterThan(femaleBack.size.width, 0)
        XCTAssertGreaterThan(femaleBack.size.height, 0)
    }

    func testViewBoxRect() {
        let vb = BodyViewBox(origin: CGPoint(x: 10, y: 20), size: CGSize(width: 100, height: 200))
        let rect = vb.rect
        XCTAssertEqual(rect.origin.x, 10)
        XCTAssertEqual(rect.origin.y, 20)
        XCTAssertEqual(rect.size.width, 100)
        XCTAssertEqual(rect.size.height, 200)
    }

    func testAllGenderSideCombinationsReturnViewBox() {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                let vb = BodyPathProvider.viewBox(gender: gender, side: side)
                XCTAssertGreaterThan(vb.size.width, 0, "\(gender) \(side) viewBox width should be > 0")
                XCTAssertGreaterThan(vb.size.height, 0, "\(gender) \(side) viewBox height should be > 0")
            }
        }
    }
}
