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
        }
    }

    /// Whether this is a cosmetic part (head/hair) rather than a muscle.
    public var isCosmeticPart: Bool {
        self == .head
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

    var muscle: Muscle? {
        switch self {
        case .hair: return nil
        default: return Muscle(rawValue: rawValue)
        }
    }
}
