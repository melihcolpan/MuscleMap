# Heatmap Guide

Visualize muscle intensity data with color-coded heatmaps.

## Overview

MuscleMap supports heatmap rendering where each muscle is colored based on an intensity value. You can use built-in color scales, apply interpolation curves, enable gradient fills, and display a legend bar.

## Color Scales

A ``HeatmapColorScale`` maps intensity values (0.0–1.0) to colors. Built-in scales include:

| Scale | Colors |
|-------|--------|
| ``HeatmapColorScale/workout`` | Gray → Yellow → Orange → Red |
| ``HeatmapColorScale/thermal`` | Blue → Green → Yellow → Red |
| ``HeatmapColorScale/medical`` | Green → Yellow → Red |
| ``HeatmapColorScale/monochrome`` | Light Gray → Dark |

### Using a Color Scale

```swift
BodyView()
    .heatmap([
        MuscleIntensity(muscle: .chest, intensity: 0.9),
        MuscleIntensity(muscle: .biceps, intensity: 0.5),
        MuscleIntensity(muscle: .abs, intensity: 0.3),
    ], colorScale: .thermal)
```

### Integer Intensities

For simpler use cases (e.g. workout trackers), use the `intensities` modifier with a 0–4 scale:

```swift
BodyView()
    .intensities([
        .chest: 4,    // maximum
        .biceps: 2,   // medium
        .abs: 1,      // low
    ], colorScale: .workout)
```

## Interpolation

Control how colors transition across the scale using ``ColorInterpolation``:

```swift
BodyView()
    .heatmap(data, colorScale: .workout)
    .heatmapInterpolation(.easeInOut)
```

Available interpolation modes:
- ``ColorInterpolation/linear`` — even distribution (default)
- ``ColorInterpolation/easeIn`` — slow start, fast end
- ``ColorInterpolation/easeOut`` — fast start, slow end
- ``ColorInterpolation/easeInOut`` — smooth S-curve
- ``ColorInterpolation/step(count:)`` — discrete color bands
- ``ColorInterpolation/custom(_:)`` — provide your own curve function

A color scale can carry its own interpolation: ``HeatmapColorScale/workoutStepped`` is the workout scale with five steps, and ``HeatmapColorScale/thermalSmooth`` eases in and out. That interpolation is used by default. An interpolation set with ``BodyView/heatmapInterpolation(_:)`` or a ``HeatmapConfiguration`` takes precedence when it is not ``ColorInterpolation/linear``.

## Gradient Fill

Enable intra-muscle gradient fills where each muscle shows a gradient from low to high intensity:

```swift
BodyView()
    .heatmap(data, colorScale: .thermal)
    .heatmapGradient(direction: .topToBottom, lowFactor: 0.3)
```

The `lowFactor` controls the intensity of the gradient's low end relative to the muscle's actual intensity.

## Threshold

Hide muscles below a minimum intensity value:

```swift
BodyView()
    .heatmap(data, colorScale: .workout)
    .heatmapThreshold(0.2) // hide muscles with intensity < 0.2
```

## Full Configuration

Use ``HeatmapConfiguration`` to combine all heatmap options:

```swift
let config = HeatmapConfiguration(
    colorScale: .thermal,
    interpolation: .easeInOut,
    threshold: 0.1,
    isGradientFillEnabled: true,
    gradientDirection: .topToBottom,
    gradientLowIntensityFactor: 0.3
)

BodyView()
    .heatmap(data, configuration: config)
```

## Legend View

Display a ``HeatmapLegendView`` alongside the body to show the color scale:

```swift
VStack {
    BodyView()
        .heatmap(data, colorScale: .workout)
        .frame(width: 200, height: 400)

    HeatmapLegendView(colorScale: .workout)
        .frame(width: 200)
}
```

Customize the legend appearance:

```swift
HeatmapLegendView(
    colorScale: .thermal,
    interpolation: .easeInOut,
    orientation: .vertical,
    barThickness: 20,
    labelMin: "Rest",
    labelMax: "Intense"
)
```
