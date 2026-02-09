import XCTest
@testable import MuscleMap

final class SVGPathParserTests: XCTestCase {

    func testParseMoveTo() {
        let commands = SVGPathParser.parse("M 10 20")
        XCTAssertEqual(commands.count, 1)
        if case .moveTo(let x, let y, let relative) = commands[0] {
            XCTAssertEqual(x, 10)
            XCTAssertEqual(y, 20)
            XCTAssertFalse(relative)
        } else {
            XCTFail("Expected moveTo command")
        }
    }

    func testParseRelativeMoveTo() {
        let commands = SVGPathParser.parse("m 5 -3")
        XCTAssertEqual(commands.count, 1)
        if case .moveTo(let x, let y, let relative) = commands[0] {
            XCTAssertEqual(x, 5)
            XCTAssertEqual(y, -3)
            XCTAssertTrue(relative)
        } else {
            XCTFail("Expected relative moveTo command")
        }
    }

    func testParseLineTo() {
        let commands = SVGPathParser.parse("M 0 0 L 100 200")
        XCTAssertEqual(commands.count, 2)
        if case .lineTo(let x, let y, let relative) = commands[1] {
            XCTAssertEqual(x, 100)
            XCTAssertEqual(y, 200)
            XCTAssertFalse(relative)
        } else {
            XCTFail("Expected lineTo command")
        }
    }

    func testParseHorizontalLineTo() {
        let commands = SVGPathParser.parse("M 0 0 H 50")
        XCTAssertEqual(commands.count, 2)
        if case .horizontalLineTo(let x, let relative) = commands[1] {
            XCTAssertEqual(x, 50)
            XCTAssertFalse(relative)
        } else {
            XCTFail("Expected horizontalLineTo command")
        }
    }

    func testParseVerticalLineTo() {
        let commands = SVGPathParser.parse("M 0 0 v 30")
        XCTAssertEqual(commands.count, 2)
        if case .verticalLineTo(let y, let relative) = commands[1] {
            XCTAssertEqual(y, 30)
            XCTAssertTrue(relative)
        } else {
            XCTFail("Expected verticalLineTo command")
        }
    }

    func testParseCurveTo() {
        let commands = SVGPathParser.parse("M 0 0 C 10 20 30 40 50 60")
        XCTAssertEqual(commands.count, 2)
        if case .curveTo(let x1, let y1, let x2, let y2, let x, let y, let relative) = commands[1] {
            XCTAssertEqual(x1, 10)
            XCTAssertEqual(y1, 20)
            XCTAssertEqual(x2, 30)
            XCTAssertEqual(y2, 40)
            XCTAssertEqual(x, 50)
            XCTAssertEqual(y, 60)
            XCTAssertFalse(relative)
        } else {
            XCTFail("Expected curveTo command")
        }
    }

    func testParseSmoothCurveTo() {
        let commands = SVGPathParser.parse("M 0 0 S 30 40 50 60")
        XCTAssertEqual(commands.count, 2)
        if case .smoothCurveTo(let x2, let y2, let x, let y, let relative) = commands[1] {
            XCTAssertEqual(x2, 30)
            XCTAssertEqual(y2, 40)
            XCTAssertEqual(x, 50)
            XCTAssertEqual(y, 60)
            XCTAssertFalse(relative)
        } else {
            XCTFail("Expected smoothCurveTo command")
        }
    }

    func testParseQuadraticCurveTo() {
        let commands = SVGPathParser.parse("M 0 0 Q 10 20 30 40")
        XCTAssertEqual(commands.count, 2)
        if case .quadraticCurveTo(let x1, let y1, let x, let y, _) = commands[1] {
            XCTAssertEqual(x1, 10)
            XCTAssertEqual(y1, 20)
            XCTAssertEqual(x, 30)
            XCTAssertEqual(y, 40)
        } else {
            XCTFail("Expected quadraticCurveTo command")
        }
    }

    func testParseSmoothQuadraticCurveTo() {
        let commands = SVGPathParser.parse("M 0 0 T 50 60")
        XCTAssertEqual(commands.count, 2)
        if case .smoothQuadraticCurveTo(let x, let y, _) = commands[1] {
            XCTAssertEqual(x, 50)
            XCTAssertEqual(y, 60)
        } else {
            XCTFail("Expected smoothQuadraticCurveTo command")
        }
    }

    func testParseArcTo() {
        let commands = SVGPathParser.parse("M 0 0 A 25 26 -80 0 1 50 25")
        XCTAssertEqual(commands.count, 2)
        if case .arcTo(let rx, let ry, let angle, let largeArc, let sweep, let x, let y, _) = commands[1] {
            XCTAssertEqual(rx, 25)
            XCTAssertEqual(ry, 26)
            XCTAssertEqual(angle, -80)
            XCTAssertFalse(largeArc)
            XCTAssertTrue(sweep)
            XCTAssertEqual(x, 50)
            XCTAssertEqual(y, 25)
        } else {
            XCTFail("Expected arcTo command")
        }
    }

    func testParseClosePath() {
        let commands = SVGPathParser.parse("M 0 0 L 10 10 Z")
        XCTAssertEqual(commands.count, 3)
        if case .closePath = commands[2] {
            // OK
        } else {
            XCTFail("Expected closePath command")
        }
    }

    func testParseClosePathLowercase() {
        let commands = SVGPathParser.parse("M 0 0 L 10 10 z")
        XCTAssertEqual(commands.count, 3)
        if case .closePath = commands[2] {
            // OK
        } else {
            XCTFail("Expected closePath command")
        }
    }

    func testParseCommaDelimitedNumbers() {
        let commands = SVGPathParser.parse("M10,20 L30,40")
        XCTAssertEqual(commands.count, 2)
        if case .moveTo(let x, let y, _) = commands[0] {
            XCTAssertEqual(x, 10)
            XCTAssertEqual(y, 20)
        } else {
            XCTFail("Expected moveTo")
        }
    }

    func testParseNegativeNumbers() {
        let commands = SVGPathParser.parse("M -10 -20")
        XCTAssertEqual(commands.count, 1)
        if case .moveTo(let x, let y, _) = commands[0] {
            XCTAssertEqual(x, -10)
            XCTAssertEqual(y, -20)
        } else {
            XCTFail("Expected moveTo")
        }
    }

    func testParseDecimalNumbers() {
        let commands = SVGPathParser.parse("M 1.5 2.75")
        XCTAssertEqual(commands.count, 1)
        if case .moveTo(let x, let y, _) = commands[0] {
            XCTAssertEqual(x, 1.5)
            XCTAssertEqual(y, 2.75)
        } else {
            XCTFail("Expected moveTo")
        }
    }

    func testParseEmptyString() {
        let commands = SVGPathParser.parse("")
        XCTAssertTrue(commands.isEmpty)
    }

    func testImplicitLineToAfterMoveTo() {
        // After M, subsequent coordinate pairs are treated as L
        let commands = SVGPathParser.parse("M 0 0 10 20 30 40")
        XCTAssertEqual(commands.count, 3)
        if case .moveTo(_, _, _) = commands[0] {} else { XCTFail("Expected moveTo") }
        if case .lineTo(let x, let y, _) = commands[1] {
            XCTAssertEqual(x, 10)
            XCTAssertEqual(y, 20)
        } else {
            XCTFail("Expected implicit lineTo")
        }
    }

    func testParseComplexPath() {
        // A real SVG path from the body data
        let path = "m 332.05,262.18 c -0.78,8.99 -5.96,18.06 -11.27,26.44 a 0.35,0.35 0 0 1 -0.59,0.01 z"
        let commands = SVGPathParser.parse(path)
        XCTAssertGreaterThan(commands.count, 0)
        // First should be moveTo
        if case .moveTo(let x, let y, let relative) = commands[0] {
            XCTAssertEqual(x, 332.05, accuracy: 0.001)
            XCTAssertEqual(y, 262.18, accuracy: 0.001)
            XCTAssertTrue(relative)
        } else {
            XCTFail("Expected moveTo")
        }
        // Last should be closePath
        if case .closePath = commands.last {} else {
            XCTFail("Expected closePath at end")
        }
    }
}
