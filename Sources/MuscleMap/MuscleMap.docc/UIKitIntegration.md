# UIKit Integration

Use MuscleMap in UIKit-based projects with ``MuscleMapView`` and ``HeatmapLegendUIView``.

## Overview

While MuscleMap is built with SwiftUI, the ``MuscleMapView`` class provides a `UIView` wrapper that can be used directly in UIKit view controllers. All configuration is exposed through mutable properties and convenience methods.

## Adding a Body View

Create a ``MuscleMapView`` and add it to your view hierarchy:

```swift
import MuscleMap

class ViewController: UIViewController {
    private let muscleMap = MuscleMapView(gender: .male, side: .front)

    override func viewDidLoad() {
        super.viewDidLoad()

        muscleMap.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(muscleMap)

        NSLayoutConstraint.activate([
            muscleMap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            muscleMap.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            muscleMap.widthAnchor.constraint(equalToConstant: 200),
            muscleMap.heightAnchor.constraint(equalToConstant: 400),
        ])
    }
}
```

## Highlighting Muscles

Use the ``MuscleMapView/highlight(_:color:opacity:)-(Muscle,_,_)`` method with UIKit colors:

```swift
muscleMap.highlight(.chest, color: .systemRed)
muscleMap.highlight(.biceps, color: .systemOrange, opacity: 0.8)
```

Or highlight multiple muscles at once:

```swift
muscleMap.highlight([.chest, .deltoids, .triceps], color: .systemBlue)
```

## Applying Heatmap Data

Use ``MuscleMapView/setIntensities(_:colorScale:)`` for integer-based workout data:

```swift
muscleMap.setIntensities([
    .chest: 4,
    .biceps: 2,
    .abs: 1
])
```

Or use ``MuscleMapView/setHeatmap(_:colorScale:)`` for normalized intensity values:

```swift
muscleMap.setHeatmap([
    MuscleIntensity(muscle: .chest, intensity: 0.9),
    MuscleIntensity(muscle: .biceps, intensity: 0.5),
])
```

## Handling Callbacks

Assign closures to respond to user interactions:

```swift
muscleMap.onMuscleSelected = { muscle, side in
    print("Selected: \(muscle.displayName)")
}

muscleMap.onMuscleLongPressed = { muscle, side in
    print("Long pressed: \(muscle.displayName)")
}
```

## Configuring Properties

All ``BodyView`` features are available as mutable properties:

```swift
muscleMap.gender = .female
muscleMap.side = .back
muscleMap.showSubGroups = true
muscleMap.isAnimated = true
muscleMap.isPulseEnabled = true
muscleMap.isZoomEnabled = true
```

## Adding a Heatmap Legend

Use ``HeatmapLegendUIView`` alongside the body view:

```swift
let legend = HeatmapLegendUIView(colorScale: .workout)
legend.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(legend)
```
