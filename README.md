# MuscleMap

A native SwiftUI SDK for rendering interactive human body muscle maps with highlighting, heatmaps, multi-select, zoom, and gesture-rich interaction.

Supports **male & female** body models with **front & back** views.

<p align="center">
  <img src="Screenshots/male_front_highlight.png" width="180" alt="Male Front">
  <img src="Screenshots/male_back_highlight.png" width="180" alt="Male Back">
  <img src="Screenshots/female_front_highlight.png" width="180" alt="Female Front">
  <img src="Screenshots/female_back_highlight.png" width="180" alt="Female Back">
</p>

## Features

- SVG-based body rendering via SwiftUI `Canvas`
- 22 muscle groups with left/right side detection
- Heatmap visualization with customizable color scales
- Tap-to-select with hit testing
- **Multi-select** (select multiple muscles at once)
- **Long press gesture** (with configurable duration)
- **Drag-to-select** (paint muscles by dragging)
- **Pinch-to-zoom & pan** (with double-tap to reset)
- **Tooltips** (custom content positioned above selected muscles)
- **Undo/redo** (selection history tracking)
- 4 preset styles (default, minimal, neon, medical)
- **Gradient fills** (linear & radial gradients)
- **Transition animations** (fade in/out on highlight changes)
- **Pulse/glow animation** (for selected muscles)
- **Shadow/drop shadow** support
- Zero external dependencies
- iOS 17+ / macOS 14+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/melihcolpan/MuscleMap.git", from: "1.2.0")
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

### Gradient Highlighting

<p align="center">
  <img src="Screenshots/gradient_linear.png" width="180" alt="Linear Gradient">
  <img src="Screenshots/gradient_radial.png" width="180" alt="Radial Gradient">
  <img src="Screenshots/gradient_neon.png" width="180" alt="Neon Gradient">
</p>

```swift
// Linear gradient (top to bottom)
BodyView(gender: .male, side: .front)
    .highlight(.chest, linearGradient: [.red, .orange], startPoint: .top, endPoint: .bottom)

// Radial gradient (center outward)
    .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 40)

// Mix gradients and solid colors
    .highlight(.quadriceps, color: .purple)
```

### Tap Detection

```swift
BodyView(gender: .female, side: .front)
    .onMuscleSelected { muscle, side in
        print("\(muscle.displayName) (\(side))")
    }
```

### Heatmap

<p align="center">
  <img src="Screenshots/heatmap_workout.png" width="200" alt="Workout Heatmap">
  <img src="Screenshots/heatmap_thermal.png" width="200" alt="Thermal Heatmap">
</p>

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

<p align="center">
  <img src="Screenshots/style_neon.png" width="200" alt="Neon Style">
  <img src="Screenshots/style_medical.png" width="200" alt="Medical Style">
</p>

```swift
BodyView(gender: .male, side: .front)
    .bodyStyle(.neon)
```

| Style | Description |
|-------|-------------|
| `.default` | Gray fill, green selection |
| `.minimal` | Subtle fill, thin strokes |
| `.neon` | Dark background, cyan selection, glow shadow |
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
    hairColor: .black,
    shadowColor: .blue.opacity(0.5),
    shadowRadius: 6,
    shadowOffset: CGSize(width: 0, height: 2)
)
```

### Animations

#### Transition Animation

Smooth fade-in/fade-out when highlights change:

```swift
BodyView(gender: .male, side: .front)
    .highlight(.chest, color: .red)
    .animated(duration: 0.3)
```

#### Pulse Animation

Pulsing glow effect on the selected muscle:

```swift
@State private var selected: Muscle?

BodyView(gender: .male, side: .front)
    .highlight(.chest, color: .red)
    .selected(selected)
    .pulseSelected(speed: 1.5, range: 0.6...1.0)
    .onMuscleSelected { muscle, _ in
        selected = muscle
    }
```

### Selection State

```swift
// Single selection (backward compatible)
@State private var selected: Muscle?

BodyView(gender: .male, side: .front)
    .selected(selected)
    .onMuscleSelected { muscle, _ in
        selected = muscle
    }
```

### Multi-Select

```swift
@State private var selectedMuscles: Set<Muscle> = []

BodyView(gender: .male, side: .front)
    .selected(selectedMuscles)
    .onMuscleSelected { muscle, _ in
        if selectedMuscles.contains(muscle) {
            selectedMuscles.remove(muscle)
        } else {
            selectedMuscles.insert(muscle)
        }
    }
```

### Long Press

```swift
BodyView(gender: .male, side: .front)
    .onMuscleLongPressed(duration: 0.5) { muscle, side in
        print("Long pressed: \(muscle.displayName)")
    }
```

### Drag-to-Select

```swift
BodyView(gender: .male, side: .front)
    .onMuscleDragged({ muscle, side in
        selectedMuscles.insert(muscle)
    }, onEnded: {
        print("Drag ended")
    })
```

### Pinch-to-Zoom

```swift
BodyView(gender: .male, side: .front)
    .zoomable(minScale: 1.0, maxScale: 4.0)
```

### Tooltips

```swift
BodyView(gender: .male, side: .front)
    .selected(selectedMuscles)
    .tooltip { muscle, side in
        Text(muscle.displayName)
            .font(.caption)
            .padding(4)
            .background(.ultraThinMaterial)
    }
```

### Undo/Redo

```swift
@State private var history = SelectionHistory()

BodyView(gender: .male, side: .front)
    .undoable(history)

Button("Undo") { if let state = history.undo() { selectedMuscles = state } }
    .disabled(!history.canUndo)
Button("Redo") { if let state = history.redo() { selectedMuscles = state } }
    .disabled(!history.canRedo)
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
