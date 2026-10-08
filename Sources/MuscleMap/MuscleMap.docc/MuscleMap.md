# ``MuscleMap``

A SwiftUI SDK for rendering interactive human body muscle maps with highlights, heatmaps, and gesture support.

## Overview

MuscleMap provides a declarative way to display a human body and visualize muscle data. Built entirely in SwiftUI with no external dependencies, it supports male and female body models, front and back views, tap/long-press/drag gestures, heatmap color scales, gradient fills, pulse animations, zoom, and more.

```swift
import MuscleMap

BodyView(gender: .male, side: .front)
    .highlight(.chest, color: .red)
    .highlight(.biceps, color: .orange, opacity: 0.8)
    .onMuscleSelected { muscle, side in
        print("Tapped \(muscle.displayName) (\(side))")
    }
```

## Topics

### Getting Started

- <doc:GettingStarted>

### Displaying Bodies

- ``BodyView``
- ``BodyGender``
- ``BodySide``

### Highlighting Muscles

- ``Muscle``
- ``MuscleSide``
- ``MuscleHighlight``
- ``MuscleFill``
- <doc:SubGroupsAndRegions>

### Heatmaps

- <doc:HeatmapGuide>
- ``MuscleIntensity``
- ``HeatmapColorScale``
- ``HeatmapConfiguration``
- ``ColorInterpolation``
- ``GradientDirection``
- ``HeatmapLegendView``

### Styling

- ``BodyViewStyle``

### Selection & History

- ``MuscleSelection``
- ``SelectionHistory``

### UIKit Integration

- <doc:UIKitIntegration>
- ``MuscleMapView``
- ``HeatmapLegendUIView``

### Accessibility and Performance

- <doc:Accessibility>
- <doc:Performance>
