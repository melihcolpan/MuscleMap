//
//  MuscleSelection.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A convenience wrapper around `Set<Muscle>` for multi-selection.
public struct MuscleSelection: Sendable, Equatable {
    public private(set) var muscles: Set<Muscle>

    public init(_ muscles: Set<Muscle> = []) {
        self.muscles = muscles
    }

    public init(_ muscles: [Muscle]) {
        self.muscles = Set(muscles)
    }

    /// Toggles the presence of a muscle in the selection.
    public mutating func toggle(_ muscle: Muscle) {
        if muscles.contains(muscle) {
            muscles.remove(muscle)
        } else {
            muscles.insert(muscle)
        }
    }

    /// Adds a muscle to the selection.
    public mutating func add(_ muscle: Muscle) {
        muscles.insert(muscle)
    }

    /// Removes a muscle from the selection.
    public mutating func remove(_ muscle: Muscle) {
        muscles.remove(muscle)
    }

    /// Whether the selection is empty.
    public var isEmpty: Bool { muscles.isEmpty }

    /// The number of selected muscles.
    public var count: Int { muscles.count }

    /// Whether the selection contains the given muscle.
    public func contains(_ muscle: Muscle) -> Bool {
        muscles.contains(muscle)
    }
}
