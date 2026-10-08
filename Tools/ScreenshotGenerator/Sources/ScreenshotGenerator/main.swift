//
//  main.swift
//  ScreenshotGenerator
//
//  Renders the body screenshots used in the README, so they can be
//  regenerated whenever the artwork or rendering changes.
//
//  Usage: swift run --package-path Tools/ScreenshotGenerator ScreenshotGenerator <output directory>
//

import AppKit
import MuscleMap
import SwiftUI

struct Screenshot {
    let name: String
    let background: Color
    let body: AnyView

    init<V: View>(_ name: String, background: Color = .white, @ViewBuilder body: () -> V) {
        self.name = name
        self.background = background
        self.body = AnyView(body())
    }
}

let screenshots: [Screenshot] = [
    Screenshot("male_front_highlight") {
        BodyView(gender: .male, side: .front)
            .intensities([.chest: 4, .deltoids: 3, .abs: 1, .biceps: 2, .forearm: 1, .quadriceps: 4, .obliques: 2])
    },
    Screenshot("male_back_highlight") {
        BodyView(gender: .male, side: .back)
            .intensities([.trapezius: 3, .upperBack: 4, .lowerBack: 2, .triceps: 2, .gluteal: 3, .hamstring: 4, .deltoids: 1])
    },
    Screenshot("female_front_highlight") {
        BodyView(gender: .female, side: .front)
            .intensities([.chest: 4, .deltoids: 4, .abs: 3, .quadriceps: 4, .calves: 1, .biceps: 2])
    },
    Screenshot("female_back_highlight") {
        BodyView(gender: .female, side: .back)
            .intensities([.trapezius: 3, .upperBack: 2, .gluteal: 4, .hamstring: 4, .calves: 1])
    },
    Screenshot("gradient_linear") {
        BodyView(gender: .male, side: .front)
            .highlight(.chest, linearGradient: [.red, .orange], startPoint: .top, endPoint: .bottom)
            .highlight(.abs, linearGradient: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
            .highlight(.deltoids, linearGradient: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
            .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 40)
            .highlight(.quadriceps, color: .purple)
    },
    Screenshot("gradient_radial") {
        BodyView(gender: .male, side: .front)
            .highlight(.chest, radialGradient: [.white, .red], center: .center, endRadius: 60)
            .highlight(.deltoids, radialGradient: [.yellow, .orange], center: .center, endRadius: 40)
            .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 40)
            .highlight(.quadriceps, radialGradient: [.white, .purple], center: .center, endRadius: 60)
    },
    Screenshot("gradient_neon", background: .black) {
        BodyView(gender: .male, side: .front)
            .bodyStyle(.neon)
            .highlight(.chest, linearGradient: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
            .highlight(.biceps, linearGradient: [.green, .teal], startPoint: .top, endPoint: .bottom)
            .highlight(.quadriceps, linearGradient: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
    },
    Screenshot("heatmap_workout") {
        BodyView(gender: .male, side: .front)
            .intensities([.chest: 3, .biceps: 2, .quadriceps: 4, .abs: 1, .deltoids: 3, .forearm: 1])
    },
    Screenshot("heatmap_thermal") {
        BodyView(gender: .male, side: .back)
            .heatmap([
                MuscleIntensity(muscle: .trapezius, intensity: 0.7),
                MuscleIntensity(muscle: .upperBack, intensity: 1.0),
                MuscleIntensity(muscle: .triceps, intensity: 0.5),
                MuscleIntensity(muscle: .lowerBack, intensity: 0.6),
                MuscleIntensity(muscle: .gluteal, intensity: 1.0),
                MuscleIntensity(muscle: .hamstring, intensity: 0.8),
                MuscleIntensity(muscle: .calves, intensity: 0.3),
            ], colorScale: .thermal)
    },
    Screenshot("heatmap_stepped") {
        BodyView(gender: .male, side: .front)
            .heatmap([
                MuscleIntensity(muscle: .chest, intensity: 0.95),
                MuscleIntensity(muscle: .deltoids, intensity: 0.7),
                MuscleIntensity(muscle: .abs, intensity: 0.45),
                MuscleIntensity(muscle: .biceps, intensity: 0.3),
                MuscleIntensity(muscle: .quadriceps, intensity: 0.85),
                MuscleIntensity(muscle: .forearm, intensity: 0.25),
            ], colorScale: .workoutStepped)
    },
    Screenshot("back_regions") {
        BodyView(gender: .male, side: .back)
            .showSubGroups()
            .highlight(.upperTrapezius, color: .orange)
            .highlight(.rhomboids, color: .red)
            .highlight(.lowerTrapezius, color: .purple)
            .highlight(.rearDeltoid, color: .blue)
            .highlight(.rotatorCuff, color: .teal)
    },
    Screenshot("style_neon", background: .black) {
        BodyView(gender: .male, side: .front)
            .bodyStyle(.neon)
            .highlight(.chest, color: .red)
            .highlight(.deltoids, color: .orange)
            .highlight(.quadriceps, color: .red, opacity: 0.8)
    },
    Screenshot("style_medical") {
        BodyView(gender: .female, side: .front)
            .bodyStyle(.medical)
            .highlight(.abs, color: .cyan)
            .highlight(.chest, color: .blue)
            .highlight(.quadriceps, color: .blue, opacity: 0.8)
    },
]

@MainActor
func render(_ screenshot: Screenshot, to directory: URL) throws {
    let content = screenshot.body
        .frame(width: 270, height: 470)
        .frame(width: 300, height: 500)
        .background(screenshot.background)
        .environment(\.colorScheme, .light)
    let renderer = ImageRenderer(content: content)
    renderer.scale = 2
    guard let image = renderer.cgImage,
          let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    let url = directory.appendingPathComponent("\(screenshot.name).png")
    try png.write(to: url)
    print("Wrote \(url.path)")
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Screenshots")
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
try MainActor.assumeIsolated {
    for screenshot in screenshots {
        try render(screenshot, to: outputDirectory)
    }
}
