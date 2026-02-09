//
//  Muscle.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents all available muscle groups that can be highlighted on the body.
public enum Muscle: String, CaseIterable, Codable, Identifiable, Sendable {
    case abs
    case adductors
    case ankles
    case biceps
    case calves
    case chest
    case deltoids
    case feet
    case forearm
    case gluteal
    case hamstring
    case hands
    case head
    case knees
    case lowerBack = "lower-back"
    case neck
    case obliques
    case quadriceps
    case tibialis
    case trapezius
    case triceps
    case upperBack = "upper-back"

    // New muscle groups
    case rotatorCuff = "rotator-cuff"
    case hipFlexors = "hip-flexors"
    case serratus
    case rhomboids

    // Sub-groups
    case upperChest = "upper-chest"
    case lowerChest = "lower-chest"
    case innerQuad = "inner-quad"
    case outerQuad = "outer-quad"
    case upperAbs = "upper-abs"
    case lowerAbs = "lower-abs"
    case frontDeltoid = "front-deltoid"
    case rearDeltoid = "rear-deltoid"
    case upperTrapezius = "upper-trapezius"
    case lowerTrapezius = "lower-trapezius"

    public var id: String { rawValue }

    /// Display name in English.
    public var displayName: String {
        switch self {
        case .abs: return "Abs"
        case .adductors: return "Adductors"
        case .ankles: return "Ankles"
        case .biceps: return "Biceps"
        case .calves: return "Calves"
        case .chest: return "Chest"
        case .deltoids: return "Deltoids"
        case .feet: return "Feet"
        case .forearm: return "Forearm"
        case .gluteal: return "Gluteal"
        case .hamstring: return "Hamstring"
        case .hands: return "Hands"
        case .head: return "Head"
        case .knees: return "Knees"
        case .lowerBack: return "Lower Back"
        case .neck: return "Neck"
        case .obliques: return "Obliques"
        case .quadriceps: return "Quadriceps"
        case .tibialis: return "Tibialis"
        case .trapezius: return "Trapezius"
        case .triceps: return "Triceps"
        case .upperBack: return "Upper Back"
        case .rotatorCuff: return "Rotator Cuff"
        case .hipFlexors: return "Hip Flexors"
        case .serratus: return "Serratus"
        case .rhomboids: return "Rhomboids"
        case .upperChest: return "Upper Chest"
        case .lowerChest: return "Lower Chest"
        case .innerQuad: return "Inner Quad"
        case .outerQuad: return "Outer Quad"
        case .upperAbs: return "Upper Abs"
        case .lowerAbs: return "Lower Abs"
        case .frontDeltoid: return "Front Deltoid"
        case .rearDeltoid: return "Rear Deltoid"
        case .upperTrapezius: return "Upper Trapezius"
        case .lowerTrapezius: return "Lower Trapezius"
        }
    }

    /// Whether this is a cosmetic part (head/hair) rather than a muscle.
    public var isCosmeticPart: Bool {
        self == .head
    }

    /// Sub-groups belonging to this muscle group. Empty if this muscle has no sub-groups.
    public var subGroups: [Muscle] {
        switch self {
        case .chest: return [.upperChest, .lowerChest]
        case .quadriceps: return [.innerQuad, .outerQuad]
        case .abs: return [.upperAbs, .lowerAbs]
        case .deltoids: return [.frontDeltoid, .rearDeltoid]
        case .trapezius: return [.upperTrapezius, .lowerTrapezius]
        default: return []
        }
    }

    /// The parent muscle group, if this muscle is a sub-group.
    public var parentGroup: Muscle? {
        switch self {
        case .upperChest, .lowerChest: return .chest
        case .innerQuad, .outerQuad: return .quadriceps
        case .upperAbs, .lowerAbs: return .abs
        case .frontDeltoid, .rearDeltoid: return .deltoids
        case .upperTrapezius, .lowerTrapezius: return .trapezius
        default: return nil
        }
    }

    /// Whether this muscle is a sub-group of another muscle.
    public var isSubGroup: Bool {
        parentGroup != nil
    }
}

/// Internal-only slug that includes hair for rendering purposes.
enum BodySlug: String, CaseIterable {
    case abs
    case adductors
    case ankles
    case biceps
    case calves
    case chest
    case deltoids
    case feet
    case forearm
    case gluteal
    case hamstring
    case hands
    case hair
    case head
    case knees
    case lowerBack = "lower-back"
    case neck
    case obliques
    case quadriceps
    case tibialis
    case trapezius
    case triceps
    case upperBack = "upper-back"

    // New muscle groups
    case rotatorCuff = "rotator-cuff"
    case hipFlexors = "hip-flexors"
    case serratus
    case rhomboids

    // Sub-groups
    case upperChest = "upper-chest"
    case lowerChest = "lower-chest"
    case innerQuad = "inner-quad"
    case outerQuad = "outer-quad"
    case upperAbs = "upper-abs"
    case lowerAbs = "lower-abs"
    case frontDeltoid = "front-deltoid"
    case rearDeltoid = "rear-deltoid"
    case upperTrapezius = "upper-trapezius"
    case lowerTrapezius = "lower-trapezius"

    var muscle: Muscle? {
        switch self {
        case .hair: return nil
        default: return Muscle(rawValue: rawValue)
        }
    }
}
