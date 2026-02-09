//
//  SelectionHistory.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Tracks selection state changes, enabling undo/redo for muscle selections.
@Observable
public final class SelectionHistory {

    /// Maximum number of entries kept in the undo stack.
    public let maxEntries: Int

    private(set) var undoStack: [Set<Muscle>] = []
    private(set) var redoStack: [Set<Muscle>] = []
    private(set) var current: Set<Muscle> = []

    /// Creates a new selection history.
    /// - Parameter maxEntries: Maximum undo steps to keep (default: 50).
    public init(maxEntries: Int = 50) {
        self.maxEntries = maxEntries
    }

    /// Pushes a new selection state. Clears the redo stack.
    public func push(_ selection: Set<Muscle>) {
        guard selection != current else { return }
        undoStack.append(current)
        if undoStack.count > maxEntries {
            undoStack.removeFirst()
        }
        current = selection
        redoStack.removeAll()
    }

    /// Reverts to the previous selection state.
    /// - Returns: The restored selection, or `nil` if nothing to undo.
    @discardableResult
    public func undo() -> Set<Muscle>? {
        guard let previous = undoStack.popLast() else { return nil }
        redoStack.append(current)
        current = previous
        return previous
    }

    /// Re-applies a previously undone selection.
    /// - Returns: The restored selection, or `nil` if nothing to redo.
    @discardableResult
    public func redo() -> Set<Muscle>? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(current)
        current = next
        return next
    }

    /// Whether there are entries to undo.
    public var canUndo: Bool { !undoStack.isEmpty }

    /// Whether there are entries to redo.
    public var canRedo: Bool { !redoStack.isEmpty }
}
