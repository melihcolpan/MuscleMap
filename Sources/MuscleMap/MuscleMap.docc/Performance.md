# Performance

Keep body views fast to appear and to redraw.

## Overview

The body artwork is a set of SVG paths. MuscleMap parses each path once, caches it for the life of the app, and only scales it for each view size. Redrawing a body, for example when a highlight changes, reuses those cached paths.

## Preloading the Artwork

Creating a ``BodyView`` starts parsing all four bodies in the background. To have the artwork ready before the first body appears, start it at launch with ``BodyView/preloadArtwork()``:

```swift
@main
struct WorkoutApp: App {
    init() {
        BodyView.preloadArtwork()
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

Calling it more than once has no extra cost.

## Swift Concurrency

On a Swift 6 toolchain, the package builds in the Swift 6 language mode with complete concurrency checking. Views are main-actor isolated like any SwiftUI view; the shared path cache is safe to use from any thread.
