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
    case obliques
    case quadriceps
    case tibialis
    case trapezius
    case triceps
    case upperBack = "upper-back"

    // New muscle groups
    /// Drawn on the back views only (infraspinatus); the front views have no path for it.
    case rotatorCuff = "rotator-cuff"
    case serratus
    /// Drawn on the back views only; the front views have no path for it.
    case rhomboids

    // Sub-groups
    case ankles
    case adductors
    case neck
    case hipFlexors = "hip-flexors"
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

    /// Localized display name for the muscle.
    public var displayName: String {
        NSLocalizedString("muscle.\(localizationKey)", bundle: .module, comment: "")
    }

    /// Key used for localization lookup. Maps Swift case names to xcstrings keys.
    private var localizationKey: String {
        switch self {
        case .abs: return "abs"
        case .adductors: return "adductors"
        case .ankles: return "ankles"
        case .biceps: return "biceps"
        case .calves: return "calves"
        case .chest: return "chest"
        case .deltoids: return "deltoids"
        case .feet: return "feet"
        case .forearm: return "forearm"
        case .gluteal: return "gluteal"
        case .hamstring: return "hamstring"
        case .hands: return "hands"
        case .head: return "head"
        case .knees: return "knees"
        case .lowerBack: return "lowerBack"
        case .neck: return "neck"
        case .obliques: return "obliques"
        case .quadriceps: return "quadriceps"
        case .tibialis: return "tibialis"
        case .trapezius: return "trapezius"
        case .triceps: return "triceps"
        case .upperBack: return "upperBack"
        case .rotatorCuff: return "rotatorCuff"
        case .hipFlexors: return "hipFlexors"
        case .serratus: return "serratus"
        case .rhomboids: return "rhomboids"
        case .upperChest: return "upperChest"
        case .lowerChest: return "lowerChest"
        case .innerQuad: return "innerQuad"
        case .outerQuad: return "outerQuad"
        case .upperAbs: return "upperAbs"
        case .lowerAbs: return "lowerAbs"
        case .frontDeltoid: return "frontDeltoid"
        case .rearDeltoid: return "rearDeltoid"
        case .upperTrapezius: return "upperTrapezius"
        case .lowerTrapezius: return "lowerTrapezius"
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
        case .quadriceps: return [.innerQuad, .outerQuad, .hipFlexors]
        case .abs: return [.upperAbs, .lowerAbs]
        case .deltoids: return [.frontDeltoid, .rearDeltoid]
        case .trapezius: return [.upperTrapezius, .lowerTrapezius]
        case .obliques: return [.serratus]
        case .feet: return [.ankles]
        case .hamstring: return [.adductors]
        case .head: return [.neck]
        default: return []
        }
    }

    /// The parent muscle group, if this muscle is a sub-group.
    public var parentGroup: Muscle? {
        switch self {
        case .upperChest, .lowerChest: return .chest
        case .innerQuad, .outerQuad, .hipFlexors: return .quadriceps
        case .upperAbs, .lowerAbs: return .abs
        case .frontDeltoid, .rearDeltoid: return .deltoids
        case .upperTrapezius, .lowerTrapezius: return .trapezius
        case .serratus: return .obliques
        case .ankles: return .feet
        case .adductors: return .hamstring
        case .neck: return .head
        default: return nil
        }
    }

    /// Whether this muscle is a sub-group of another muscle.
    public var isSubGroup: Bool {
        parentGroup != nil
    }

    /// The muscle whose artwork this region lies in, if any.
    ///
    /// The region resolves taps to the host when sub-groups are hidden, and the host's
    /// bounding rect includes it. A carved region (rotator cuff) is always drawn and shows
    /// the host's highlight when it has none of its own; an overlay region (rhomboids)
    /// is drawn only while highlighted, see `isOverlayRegion`. Unlike a sub-group it is
    /// not part of `parentGroup`, because it is not anatomically part of the host muscle.
    var regionHost: Muscle? {
        switch self {
        case .rhomboids: return .trapezius
        case .rotatorCuff: return .upperBack
        default: return nil
        }
    }

    /// Whether this region is drawn on top of its host only while it is highlighted or
    /// selected. The host's artwork stays whole, so an unhighlighted body looks exactly
    /// as it did before the region existed.
    var isOverlayRegion: Bool {
        self == .rhomboids
    }

    /// The muscle whose highlight, selection and taps this one stands in for when
    /// sub-groups are hidden.
    var defaultModeHost: Muscle? {
        if isAlwaysVisibleSubGroup { return parentGroup }
        return regionHost
    }

    /// Whether this sub-group is always rendered even when sub-groups are hidden.
    /// When tapped in default mode, the parent muscle is returned instead.
    public var isAlwaysVisibleSubGroup: Bool {
        switch self {
        case .ankles, .adductors, .neck: return true
        default: return false
        }
    }
}

// MARK: - Drawability

extension Muscle {

    /// Whether this muscle has a path in the given body, i.e. highlighting it there paints something.
    public func isDrawable(gender: BodyGender, side: BodySide) -> Bool {
        BodyPathProvider.paths(gender: gender, side: side).contains { $0.slug.muscle == self }
    }

    /// Whether this muscle has a path in at least one body (male/female, front/back).
    ///
    /// Some public cases have no artwork yet, and some are drawn on the back views only;
    /// use this or `isDrawable(gender:side:)` to validate a muscle mapping in tests.
    public var isDrawable: Bool {
        Self.drawableMuscles.contains(self)
    }

    private static let drawableMuscles: Set<Muscle> = {
        var result = Set<Muscle>()
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                for part in BodyPathProvider.paths(gender: gender, side: side) {
                    if let muscle = part.slug.muscle { result.insert(muscle) }
                }
            }
        }
        return result
    }()
}

/// Internal-only slug that includes hair for rendering purposes.
enum BodySlug: String, CaseIterable {
    case abs
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
    case obliques
    case quadriceps
    case tibialis
    case trapezius
    case triceps
    case upperBack = "upper-back"

    // New muscle groups
    case rotatorCuff = "rotator-cuff"
    case serratus
    case rhomboids

    // Sub-groups
    case ankles
    case adductors
    case neck
    case hipFlexors = "hip-flexors"
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
