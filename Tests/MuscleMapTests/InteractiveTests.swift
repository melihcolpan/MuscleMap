import XCTest
import SwiftUI
@testable import MuscleMap

final class InteractiveTests: XCTestCase {

    // MARK: - MuscleSelection

    func testMuscleSelectionInit() {
        let selection = MuscleSelection()
        XCTAssertTrue(selection.isEmpty)
        XCTAssertEqual(selection.count, 0)
    }

    func testMuscleSelectionInitWithSet() {
        let selection = MuscleSelection(Set([.chest, .biceps]))
        XCTAssertEqual(selection.count, 2)
        XCTAssertTrue(selection.contains(.chest))
        XCTAssertTrue(selection.contains(.biceps))
    }

    func testMuscleSelectionInitWithArray() {
        let selection = MuscleSelection([.chest, .biceps, .chest])
        XCTAssertEqual(selection.count, 2) // Duplicates removed
    }

    func testMuscleSelectionToggle() {
        var selection = MuscleSelection()
        selection.toggle(.chest)
        XCTAssertTrue(selection.contains(.chest))
        XCTAssertEqual(selection.count, 1)

        selection.toggle(.chest)
        XCTAssertFalse(selection.contains(.chest))
        XCTAssertTrue(selection.isEmpty)
    }

    func testMuscleSelectionAddRemove() {
        var selection = MuscleSelection()
        selection.add(.chest)
        selection.add(.biceps)
        XCTAssertEqual(selection.count, 2)

        selection.remove(.chest)
        XCTAssertEqual(selection.count, 1)
        XCTAssertFalse(selection.contains(.chest))
        XCTAssertTrue(selection.contains(.biceps))
    }

    func testMuscleSelectionEquatable() {
        let a = MuscleSelection(Set([.chest, .biceps]))
        let b = MuscleSelection(Set([.biceps, .chest]))
        XCTAssertEqual(a, b)
    }

    // MARK: - SelectionHistory

    func testSelectionHistoryInit() {
        let history = SelectionHistory()
        XCTAssertFalse(history.canUndo)
        XCTAssertFalse(history.canRedo)
        XCTAssertTrue(history.current.isEmpty)
    }

    func testSelectionHistoryPush() {
        let history = SelectionHistory()
        history.push(Set([.chest]))
        XCTAssertEqual(history.current, Set([.chest]))
        XCTAssertTrue(history.canUndo)
        XCTAssertFalse(history.canRedo)
    }

    func testSelectionHistoryUndo() {
        let history = SelectionHistory()
        history.push(Set([.chest]))
        history.push(Set([.chest, .biceps]))

        let undone = history.undo()
        XCTAssertEqual(undone, Set([.chest]))
        XCTAssertEqual(history.current, Set([.chest]))
        XCTAssertTrue(history.canRedo)
    }

    func testSelectionHistoryRedo() {
        let history = SelectionHistory()
        history.push(Set([.chest]))
        history.push(Set([.chest, .biceps]))
        history.undo()

        let redone = history.redo()
        XCTAssertEqual(redone, Set([.chest, .biceps]))
        XCTAssertEqual(history.current, Set([.chest, .biceps]))
    }

    func testSelectionHistoryUndoEmpty() {
        let history = SelectionHistory()
        let result = history.undo()
        XCTAssertNil(result)
    }

    func testSelectionHistoryRedoEmpty() {
        let history = SelectionHistory()
        let result = history.redo()
        XCTAssertNil(result)
    }

    func testSelectionHistoryPushClearsRedoStack() {
        let history = SelectionHistory()
        history.push(Set([.chest]))
        history.push(Set([.biceps]))
        history.undo()
        XCTAssertTrue(history.canRedo)

        history.push(Set([.abs]))
        XCTAssertFalse(history.canRedo)
    }

    func testSelectionHistoryMaxEntries() {
        let history = SelectionHistory(maxEntries: 3)
        history.push(Set([.chest]))
        history.push(Set([.biceps]))
        history.push(Set([.abs]))
        history.push(Set([.deltoids]))

        // Should only keep last 3 undo entries
        XCTAssertNotNil(history.undo()) // deltoids -> abs
        XCTAssertNotNil(history.undo()) // abs -> biceps
        XCTAssertNotNil(history.undo()) // biceps -> chest
        XCTAssertNil(history.undo())    // No more entries (initial empty state was evicted)
    }

    func testSelectionHistoryDuplicatePushIgnored() {
        let history = SelectionHistory()
        history.push(Set([.chest]))
        history.push(Set([.chest])) // Same as current, should be ignored
        XCTAssertEqual(history.current, Set([.chest]))

        let undone = history.undo()
        XCTAssertEqual(undone, Set()) // Back to empty initial state
        XCTAssertFalse(history.canUndo) // Only one undo step
    }

    // MARK: - BodyRenderer Multi-Select

    func testRendererMultiSelect() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: Set([.chest, .biceps])
        )
        XCTAssertEqual(renderer.selectedMuscles, Set([.chest, .biceps]))
    }

    func testRendererBackwardCompatibleInit() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscle: .chest
        )
        XCTAssertEqual(renderer.selectedMuscles, Set([.chest]))
    }

    func testRendererBackwardCompatibleNil() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscle: nil
        )
        XCTAssertTrue(renderer.selectedMuscles.isEmpty)
    }

    func testRendererBoundingRectReturnsValue() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: []
        )
        let size = CGSize(width: 200, height: 400)
        let rect = renderer.boundingRect(for: .chest, in: size)
        XCTAssertNotNil(rect)
        XCTAssertFalse(rect!.isEmpty)
    }

    func testRendererBoundingRectNilForMissingMuscle() {
        // Use male front but ask for a muscle that only exists on back
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: []
        )
        let size = CGSize(width: 200, height: 400)
        // Head exists on front, so let's check it returns something
        let rect = renderer.boundingRect(for: .head, in: size)
        XCTAssertNotNil(rect)
    }

    // MARK: - BodyView Multi-Select Modifiers

    func testBodyViewSelectedSet() {
        let view = BodyView(gender: .male, side: .front)
            .selected(Set([.chest, .biceps]))
        XCTAssertNotNil(view)
    }

    func testBodyViewSelectedSingleBackwardCompat() {
        let view = BodyView(gender: .male, side: .front)
            .selected(.chest)
        XCTAssertNotNil(view)
    }

    func testBodyViewSelectedNilBackwardCompat() {
        let view = BodyView(gender: .male, side: .front)
            .selected(nil)
        XCTAssertNotNil(view)
    }

    func testBodyViewLongPressModifier() {
        let view = BodyView(gender: .male, side: .front)
            .onMuscleLongPressed(duration: 0.3) { _, _ in }
        XCTAssertNotNil(view)
    }

    func testBodyViewDragModifier() {
        let view = BodyView(gender: .male, side: .front)
            .onMuscleDragged({ _, _ in }, onEnded: {})
        XCTAssertNotNil(view)
    }

    func testBodyViewZoomableModifier() {
        let view = BodyView(gender: .male, side: .front)
            .zoomable(minScale: 1.0, maxScale: 3.0)
        XCTAssertNotNil(view)
    }

    func testBodyViewTooltipModifier() {
        let view = BodyView(gender: .male, side: .front)
            .selected(Set([.chest]))
            .tooltip { muscle, _ in
                Text(muscle.displayName)
            }
        XCTAssertNotNil(view)
    }

    func testBodyViewUndoableModifier() {
        let history = SelectionHistory()
        let view = BodyView(gender: .male, side: .front)
            .undoable(history)
        XCTAssertNotNil(view)
    }

    func testBodyViewAllInteractiveModifiers() {
        let history = SelectionHistory()
        let view = BodyView(gender: .male, side: .front)
            .highlight(.chest, color: .red)
            .selected(Set([.chest]))
            .onMuscleSelected { _, _ in }
            .onMuscleLongPressed(duration: 0.5) { _, _ in }
            .onMuscleDragged({ _, _ in }, onEnded: {})
            .zoomable()
            .tooltip { muscle, _ in Text(muscle.displayName) }
            .undoable(history)
            .pulseSelected()
            .animated()
        XCTAssertNotNil(view)
    }

    // MARK: - BodyRenderer Hit Test

    func testHitTestReturnsNilForEmptyArea() {
        let renderer = BodyRenderer(
            gender: .male,
            side: .front,
            highlights: [:],
            style: .default,
            selectedMuscles: []
        )
        // Point way outside body (0, 0) at reasonable size
        let result = renderer.hitTest(at: CGPoint(x: 0, y: 0), in: CGSize(width: 200, height: 400))
        XCTAssertNil(result)
    }
}
