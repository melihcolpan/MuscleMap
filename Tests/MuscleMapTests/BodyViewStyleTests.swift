import XCTest
import SwiftUI
@testable import MuscleMap

final class BodyViewStyleTests: XCTestCase {

    func testDefaultStyle() {
        let style = BodyViewStyle.default
        XCTAssertEqual(style.strokeWidth, 0)
        XCTAssertEqual(style.selectionStrokeWidth, 2)
    }

    func testMinimalStyle() {
        let style = BodyViewStyle.minimal
        XCTAssertEqual(style.strokeWidth, 0.5)
        XCTAssertEqual(style.selectionStrokeWidth, 1.5)
    }

    func testNeonStyle() {
        let style = BodyViewStyle.neon
        XCTAssertEqual(style.strokeWidth, 0.5)
        XCTAssertEqual(style.selectionStrokeWidth, 2)
    }

    func testMedicalStyle() {
        let style = BodyViewStyle.medical
        XCTAssertEqual(style.strokeWidth, 0.5)
        XCTAssertEqual(style.selectionStrokeWidth, 2)
    }

    func testCustomStyle() {
        let style = BodyViewStyle(
            defaultFillColor: .blue,
            strokeColor: .white,
            strokeWidth: 3,
            selectionColor: .yellow,
            selectionStrokeColor: .yellow,
            selectionStrokeWidth: 4,
            headColor: .gray,
            hairColor: .black
        )
        XCTAssertEqual(style.strokeWidth, 3)
        XCTAssertEqual(style.selectionStrokeWidth, 4)
    }
}
