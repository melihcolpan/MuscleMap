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
        XCTAssertEqual(style.shadowRadius, 8)
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

    // MARK: - Shadow Properties

    func testDefaultStyleShadow() {
        let style = BodyViewStyle.default
        XCTAssertEqual(style.shadowRadius, 0)
        XCTAssertEqual(style.shadowOffset, .zero)
    }

    func testMinimalStyleShadow() {
        let style = BodyViewStyle.minimal
        XCTAssertEqual(style.shadowRadius, 0)
    }

    func testNeonStyleShadow() {
        let style = BodyViewStyle.neon
        XCTAssertEqual(style.shadowRadius, 8)
        // shadowColor is cyan with opacity - just check radius is set
        XCTAssertGreaterThan(style.shadowRadius, 0)
    }

    func testMedicalStyleShadow() {
        let style = BodyViewStyle.medical
        XCTAssertEqual(style.shadowRadius, 0)
    }

    func testCustomShadowStyle() {
        let style = BodyViewStyle(
            shadowColor: .purple,
            shadowRadius: 12,
            shadowOffset: CGSize(width: 2, height: 4)
        )
        XCTAssertEqual(style.shadowRadius, 12)
        XCTAssertEqual(style.shadowOffset, CGSize(width: 2, height: 4))
    }
}
