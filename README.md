# MuscleMap

A native SwiftUI SDK for rendering interactive human body muscle maps with highlighting, heatmaps, and tap-to-select functionality.

Supports **male & female** body models with **front & back** views.

## Features

- SVG-based body rendering via SwiftUI `Canvas`
- 22 muscle groups with left/right side detection
- Heatmap visualization with customizable color scales
- Tap-to-select with hit testing
- 4 preset styles (default, minimal, neon, medical)
- Zero external dependencies
- iOS 17+ / macOS 14+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/user/MuscleMap.git", from: "1.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and paste the repository URL.

## Quick Start

```swift
import SwiftUI
import MuscleMap

struct ContentView: View {
    var body: some View {
        BodyView(gender: .male, side: .front)
            .highlight(.chest, color: .red)
            .highlight(.biceps, color: .orange, opacity: 0.8)
            .frame(height: 400)
    }
}
```

## Usage

### Basic Highlighting

```swift
BodyView(gender: .male, side: .front)
    .highlight(.chest, color: .red)
    .highlight(.abs, color: .yellow, opacity: 0.6)
    .highlight([.quadriceps, .calves], color: .orange)
```

### Tap Detection

```swift
BodyView(gender: .female, side: .front)
    .onMuscleSelected { muscle, side in
        print("\(muscle.displayName) (\(side))")
    }
```

### Heatmap

```swift
// Integer scale (0-4, like workout trackers)
BodyView(gender: .male, side: .front)
    .intensities([
        .chest: 3,
        .biceps: 2,
        .quadriceps: 4,
        .abs: 1
    ])

// Custom intensity data (0.0 - 1.0)
let data = [
    MuscleIntensity(muscle: .chest, intensity: 0.8),
    MuscleIntensity(muscle: .biceps, intensity: 0.5, side: .left),
    MuscleIntensity(muscle: .abs, intensity: 0.3, color: .purple)
]
BodyView(gender: .male, side: .front)
    .heatmap(data, colorScale: .thermal)
```

### Color Scales

| Scale | Colors |
|-------|--------|
| `.workout` | gray -> yellow -> orange -> red |
| `.thermal` | blue -> green -> yellow -> red |
| `.medical` | green -> yellow -> red |
| `.monochrome` | light gray -> dark |

Custom:
```swift
let custom = HeatmapColorScale(colors: [.blue, .purple, .pink])
```

### Styles

```swift
BodyView(gender: .male, side: .front)
    .bodyStyle(.neon)
```

| Style | Description |
|-------|-------------|
| `.default` | Gray fill, green selection |
| `.minimal` | Subtle fill, thin strokes |
| `.neon` | Dark background, cyan selection |
| `.medical` | Clinical blue-gray tones |

Custom:
```swift
let style = BodyViewStyle(
    defaultFillColor: .gray,
    strokeColor: .white,
    strokeWidth: 1,
    selectionColor: .yellow,
    selectionStrokeColor: .yellow,
    selectionStrokeWidth: 3,
    headColor: .gray,
    hairColor: .black
)
```

### Selection State

```swift
@State private var selected: Muscle?

BodyView(gender: .male, side: .front)
    .selected(selected)
    .onMuscleSelected { muscle, _ in
        selected = muscle
    }
```

### Gender & Side

```swift
BodyView(gender: .male, side: .front)   // Male front
BodyView(gender: .male, side: .back)    // Male back
BodyView(gender: .female, side: .front) // Female front
BodyView(gender: .female, side: .back)  // Female back
```

## Available Muscles

| Muscle | Key |
|--------|-----|
| Abs | `.abs` |
| Adductors | `.adductors` |
| Ankles | `.ankles` |
| Biceps | `.biceps` |
| Calves | `.calves` |
| Chest | `.chest` |
| Deltoids | `.deltoids` |
| Feet | `.feet` |
| Forearm | `.forearm` |
| Gluteal | `.gluteal` |
| Hamstring | `.hamstring` |
| Hands | `.hands` |
| Head | `.head` |
| Knees | `.knees` |
| Lower Back | `.lowerBack` |
| Neck | `.neck` |
| Obliques | `.obliques` |
| Quadriceps | `.quadriceps` |
| Tibialis | `.tibialis` |
| Trapezius | `.trapezius` |
| Triceps | `.triceps` |
| Upper Back | `.upperBack` |

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 5.9+

## License

MIT License. See [LICENSE](LICENSE) for details.

