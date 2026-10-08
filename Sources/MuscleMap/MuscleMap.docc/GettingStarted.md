# Getting Started with MuscleMap

Add MuscleMap to your project and display an interactive body view in minutes.

## Overview

MuscleMap is a pure SwiftUI package with no external dependencies. It supports iOS 17+ and macOS 14+.

## Adding MuscleMap to Your Project

With CocoaPods, add `pod 'MuscleMap', '~> 1.9.0'` to your `Podfile`. With Swift Package Manager:

Add MuscleMap as a Swift Package dependency in Xcode:

1. Open your project in Xcode.
2. Go to **File → Add Package Dependencies**.
3. Enter `https://github.com/melihcolpan/MuscleMap.git`.
4. Select the latest version and add it to your target.

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/melihcolpan/MuscleMap.git", from: "1.9.0")
]
```

Then add `MuscleMap` as a dependency to your target:

```swift
.target(name: "YourApp", dependencies: ["MuscleMap"])
```

## Displaying a Body

Import the module and use ``BodyView``:

```swift
import MuscleMap

struct ContentView: View {
    var body: some View {
        BodyView(gender: .male, side: .front)
            .frame(width: 200, height: 400)
    }
}
```

Choose between ``BodyGender/male`` and ``BodyGender/female`` models, and ``BodySide/front`` or ``BodySide/back`` views.

## Highlighting Muscles

Use the `highlight` modifier to color individual muscles:

```swift
BodyView()
    .highlight(.chest, color: .red)
    .highlight(.biceps, color: .orange, opacity: 0.8)
    .highlight(.abs, color: .yellow, opacity: 0.6)
```

Highlight multiple muscles at once:

```swift
BodyView()
    .highlight([.chest, .deltoids, .triceps], color: .blue)
```

## Handling Taps

Respond to muscle taps with ``BodyView/onMuscleSelected(_:)``:

```swift
BodyView()
    .onMuscleSelected { muscle, side in
        print("\(muscle.displayName) tapped on \(side)")
    }
```

## Intensity-Based Coloring

Use the `intensities` modifier with a 0–4 scale (common in workout trackers):

```swift
BodyView()
    .intensities([
        .chest: 4,
        .biceps: 2,
        .abs: 1,
        .quadriceps: 3
    ])
```

## Next Steps

- Learn about heatmaps and color scales in <doc:HeatmapGuide>.
- Use MuscleMap from UIKit with <doc:UIKitIntegration>.
