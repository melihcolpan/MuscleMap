//
//  BodyViewStyle.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-09.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Configuration for the visual appearance of a BodyView.
public struct BodyViewStyle: Sendable {
    public var defaultFillColor: Color
    public var strokeColor: Color
    public var strokeWidth: CGFloat
    public var selectionColor: Color
    public var selectionStrokeColor: Color
    public var selectionStrokeWidth: CGFloat
    public var headColor: Color
    public var hairColor: Color
    public var shadowColor: Color
    public var shadowRadius: CGFloat
    public var shadowOffset: CGSize

    public init(
        defaultFillColor: Color = .mmDefaultFill,
        strokeColor: Color = .clear,
        strokeWidth: CGFloat = 0,
        selectionColor: Color = .green,
        selectionStrokeColor: Color = .green,
        selectionStrokeWidth: CGFloat = 2,
        headColor: Color = Color(white: 0.75),
        hairColor: Color = Color(white: 0.25),
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0,
        shadowOffset: CGSize = .zero
    ) {
        self.defaultFillColor = defaultFillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.selectionColor = selectionColor
        self.selectionStrokeColor = selectionStrokeColor
        self.selectionStrokeWidth = selectionStrokeWidth
        self.headColor = headColor
        self.hairColor = hairColor
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
}

// MARK: - Preset Styles

extension BodyViewStyle {

    /// Default style with gray fill and green selection.
    public static let `default` = BodyViewStyle()

    /// Minimal style with thin strokes and subtle fill.
    public static let minimal = BodyViewStyle(
        defaultFillColor: .mmLighterFill,
        strokeColor: .mmMediumFill,
        strokeWidth: 0.5,
        selectionStrokeWidth: 1.5
    )

    /// Neon style with dark background tones and glow shadow.
    public static let neon = BodyViewStyle(
        defaultFillColor: Color(white: 0.15),
        strokeColor: Color(white: 0.3),
        strokeWidth: 0.5,
        selectionColor: .cyan,
        selectionStrokeColor: .cyan,
        selectionStrokeWidth: 2,
        headColor: Color(white: 0.2),
        hairColor: Color(white: 0.1),
        shadowColor: .cyan.opacity(0.6),
        shadowRadius: 8
    )

    /// Medical/clinical style.
    public static let medical = BodyViewStyle(
        defaultFillColor: Color(red: 0.9, green: 0.92, blue: 0.95),
        strokeColor: Color(red: 0.7, green: 0.75, blue: 0.8),
        strokeWidth: 0.5,
        selectionColor: .blue,
        selectionStrokeColor: .blue,
        selectionStrokeWidth: 2,
        headColor: Color(red: 0.85, green: 0.87, blue: 0.9),
        hairColor: Color(red: 0.3, green: 0.32, blue: 0.35)
    )
}
