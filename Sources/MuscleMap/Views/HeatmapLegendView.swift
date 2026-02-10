//
//  HeatmapLegendView.swift
//  MuscleMap
//
//  Created by Melih Colpan on 2026-02-10.
//  Copyright © 2026 Melih Colpan. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A color bar legend that displays the heatmap color scale.
public struct HeatmapLegendView: View {

    /// The color scale to display.
    public let colorScale: HeatmapColorScale

    /// The interpolation curve applied to the color bar.
    public var interpolation: ColorInterpolation

    /// Orientation of the legend bar.
    public var orientation: Axis

    /// Height (or width, if vertical) of the color bar.
    public var barThickness: CGFloat

    /// Label displayed at the low end of the scale.
    public var labelMin: String

    /// Label displayed at the high end of the scale.
    public var labelMax: String

    /// Number of color samples used to render the gradient bar.
    public var steps: Int

    public init(
        colorScale: HeatmapColorScale,
        interpolation: ColorInterpolation = .linear,
        orientation: Axis = .horizontal,
        barThickness: CGFloat = 16,
        labelMin: String? = nil,
        labelMax: String? = nil,
        steps: Int = 32
    ) {
        self.colorScale = colorScale
        self.interpolation = interpolation
        self.orientation = orientation
        self.barThickness = barThickness
        self.labelMin = labelMin ?? NSLocalizedString("legend.low", bundle: .module, comment: "")
        self.labelMax = labelMax ?? NSLocalizedString("legend.high", bundle: .module, comment: "")
        self.steps = max(steps, 2)
    }

    public var body: some View {
        if orientation == .horizontal {
            horizontalLayout
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("accessibility.heatmapLegend", bundle: .module, comment: ""))
        } else {
            verticalLayout
                .accessibilityElement(children: .combine)
                .accessibilityLabel(NSLocalizedString("accessibility.heatmapLegend", bundle: .module, comment: ""))
        }
    }

    // MARK: - Layouts

    @ViewBuilder
    private var horizontalLayout: some View {
        VStack(spacing: 4) {
            colorBar
                .frame(height: barThickness)
                .clipShape(RoundedRectangle(cornerRadius: barThickness / 4))
            HStack {
                Text(labelMin)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(labelMax)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var verticalLayout: some View {
        HStack(spacing: 4) {
            VStack {
                Text(labelMax)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(labelMin)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            colorBar
                .frame(width: barThickness)
                .clipShape(RoundedRectangle(cornerRadius: barThickness / 4))
        }
    }

    // MARK: - Color Bar

    @ViewBuilder
    private var colorBar: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let isHorizontal = orientation == .horizontal
                let count = steps
                for i in 0..<count {
                    let t = Double(i) / Double(count - 1)
                    let curved = interpolation.apply(t)
                    let color = colorScale.color(for: curved)

                    let rect: CGRect
                    if isHorizontal {
                        let stepWidth = size.width / CGFloat(count)
                        rect = CGRect(
                            x: CGFloat(i) * stepWidth,
                            y: 0,
                            width: stepWidth + 1, // +1 to avoid gaps
                            height: size.height
                        )
                    } else {
                        let stepHeight = size.height / CGFloat(count)
                        // Vertical: top = high, bottom = low
                        let invertedI = count - 1 - i
                        rect = CGRect(
                            x: 0,
                            y: CGFloat(invertedI) * stepHeight,
                            width: size.width,
                            height: stepHeight + 1
                        )
                    }
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Horizontal Legend") {
    VStack(spacing: 20) {
        HeatmapLegendView(colorScale: .workout)
            .frame(width: 200)
        HeatmapLegendView(colorScale: .thermal, interpolation: .easeInOut)
            .frame(width: 200)
        HeatmapLegendView(colorScale: .workoutStepped)
            .frame(width: 200)
    }
    .padding()
}

#Preview("Vertical Legend") {
    HeatmapLegendView(
        colorScale: .thermal,
        orientation: .vertical,
        barThickness: 20
    )
    .frame(width: 60, height: 200)
    .padding()
}
