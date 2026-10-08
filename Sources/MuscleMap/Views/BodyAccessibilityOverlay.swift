//
//  BodyAccessibilityOverlay.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// An invisible overlay that exposes each visible muscle as an accessibility element for VoiceOver.
struct BodyAccessibilityOverlay: View {

    let gender: BodyGender
    let side: BodySide
    let highlights: [Muscle: MuscleHighlight]
    let style: BodyViewStyle
    let selectedMuscles: Set<Muscle>
    let size: CGSize
    let onMuscleSelected: ((Muscle, MuscleSide) -> Void)?
    let onMuscleLongPressed: ((Muscle, MuscleSide) -> Void)?
    var hideSubGroups: Bool = true

    var body: some View {
        let renderer = BodyRenderer(
            gender: gender,
            side: side,
            highlights: highlights,
            style: style,
            selectedMuscles: selectedMuscles,
            hideSubGroups: hideSubGroups
        )
        let muscles = visibleMuscles(renderer: renderer)

        ZStack {
            ForEach(muscles, id: \.id) { item in
                accessibilityElement(for: item)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("accessibility.bodyMap", bundle: .module, comment: ""))
    }

    @ViewBuilder
    private func accessibilityElement(for item: MuscleAccessibilityItem) -> some View {
        let isSelected = selectedMuscles.contains(item.muscle)
        let valueKey = isSelected ? "accessibility.selected" : "accessibility.notSelected"
        let hintKey = onMuscleLongPressed != nil ? "accessibility.hint.longPress" : "accessibility.hint.tap"
        let traits: AccessibilityTraits = isSelected ? [.isButton, .isSelected] : [.isButton]

        Color.clear
            .frame(width: item.rect.width, height: item.rect.height)
            .position(x: item.rect.midX, y: item.rect.midY)
            .accessibilityElement()
            .accessibilityLabel(item.label)
            .accessibilityValue(NSLocalizedString(valueKey, bundle: .module, comment: ""))
            .accessibilityHint(NSLocalizedString(hintKey, bundle: .module, comment: ""))
            .accessibilityAddTraits(traits)
            .accessibilityAction(.default) {
                onMuscleSelected?(item.muscle, item.side)
            }
            .accessibilityAction(named: Text(NSLocalizedString("accessibility.hint.longPress", bundle: .module, comment: ""))) {
                onMuscleLongPressed?(item.muscle, item.side)
            }
    }

    // MARK: - Private

    /// Returns visible muscles sorted top-to-bottom for natural VoiceOver traversal.
    /// Muscles drawn on both sides get one element per side, read left then right.
    /// Excludes cosmetic parts (e.g., head).
    func visibleMuscles(renderer: BodyRenderer) -> [MuscleAccessibilityItem] {
        let bodyParts = BodyPathProvider.paths(gender: gender, side: side)
        var seen = Set<Muscle>()
        var groups: [[MuscleAccessibilityItem]] = []

        for bodyPart in bodyParts {
            guard let muscle = bodyPart.slug.muscle,
                  !muscle.isCosmeticPart,
                  !seen.contains(muscle) else { continue }
            if hideSubGroups && muscle.isSubGroup && !muscle.isAlwaysVisibleSubGroup { continue }
            seen.insert(muscle)

            let left = renderer.boundingRect(for: muscle, muscleSide: .left, in: size)
            let right = renderer.boundingRect(for: muscle, muscleSide: .right, in: size)
            var group: [MuscleAccessibilityItem] = []
            if let left, let right, !left.isEmpty, !right.isEmpty {
                group = [
                    MuscleAccessibilityItem(muscle: muscle, side: .left, rect: left),
                    MuscleAccessibilityItem(muscle: muscle, side: .right, rect: right),
                ].sorted { $0.rect.minX < $1.rect.minX }
            } else if let rect = renderer.boundingRect(for: muscle, in: size), !rect.isEmpty {
                group = [MuscleAccessibilityItem(muscle: muscle, side: .both, rect: rect)]
            }
            if !group.isEmpty { groups.append(group) }
        }

        // Sort top-to-bottom (by minY) for anatomical VoiceOver traversal, keeping sides together
        groups.sort { a, b in
            a.map(\.rect.minY).min()! < b.map(\.rect.minY).min()!
        }
        return groups.flatMap { $0 }
    }
}

/// A muscle (or one side of it) with its bounding rect for accessibility layout.
struct MuscleAccessibilityItem {
    let muscle: Muscle
    let side: MuscleSide
    let rect: CGRect

    var id: String { "\(muscle.rawValue)-\(side.rawValue)" }

    /// "Biceps" for a single region, "Biceps, Left" for one side of a pair.
    var label: String {
        guard side != .both else { return muscle.displayName }
        let format = NSLocalizedString("accessibility.muscleWithSide", bundle: .module, comment: "Muscle name, then side")
        return String(format: format, muscle.displayName, side.displayName)
    }
}
