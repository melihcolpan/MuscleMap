import XCTest
import SwiftUI
import ImageIO
import UniformTypeIdentifiers
@testable import MuscleMap

/// Renders each body and compares it with a reference image in `__Snapshots__`.
///
/// Catches artwork and layout regressions such as a body shifted inside its view box.
/// To record new references after an intended visual change, run:
///
///     MUSCLEMAP_RECORD_SNAPSHOTS=1 swift test --filter SnapshotTests
///
/// Small anti-aliasing differences between machines are tolerated.
@MainActor
final class SnapshotTests: XCTestCase {

    private let size = CGSize(width: 200, height: 400)

    /// A pixel counts as different when any channel differs by more than this (0-255).
    private let channelTolerance = 24
    /// The snapshot fails when more than this fraction of pixels differ.
    private let maxDifferentFraction = 0.002

    // Fixed sRGB colors: system colors such as .red and .orange change between OS
    // releases (they did in macOS 26), which would fail snapshots that are still correct.
    private static let orange = Color(.sRGB, red: 1.0, green: 0.55, blue: 0.1)
    private static let red = Color(.sRGB, red: 0.9, green: 0.2, blue: 0.2)
    private static let purple = Color(.sRGB, red: 0.55, green: 0.3, blue: 0.85)
    private static let blue = Color(.sRGB, red: 0.15, green: 0.45, blue: 0.95)
    private static let teal = Color(.sRGB, red: 0.1, green: 0.65, blue: 0.65)
    private static let yellow = Color(.sRGB, red: 1.0, green: 0.85, blue: 0.2)

    private let colorScale = HeatmapColorScale(colors: [
        Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8), SnapshotTests.yellow, SnapshotTests.orange, SnapshotTests.red,
    ])

    private let heatmap: [MuscleIntensity] = [
        MuscleIntensity(muscle: .chest, intensity: 0.9),
        MuscleIntensity(muscle: .trapezius, intensity: 0.7),
        MuscleIntensity(muscle: .deltoids, intensity: 0.5),
        MuscleIntensity(muscle: .upperBack, intensity: 0.8),
        MuscleIntensity(muscle: .quadriceps, intensity: 0.6),
        MuscleIntensity(muscle: .hamstring, intensity: 0.4),
        MuscleIntensity(muscle: .feet, intensity: 1.0),
    ]

    func testBodies() throws {
        for gender in BodyGender.allCases {
            for side in BodySide.allCases {
                try assertSnapshot(BodyView(gender: gender, side: side), named: "\(gender.rawValue)_\(side.rawValue)")
                try assertSnapshot(
                    BodyView(gender: gender, side: side).heatmap(heatmap, colorScale: colorScale),
                    named: "\(gender.rawValue)_\(side.rawValue)_heatmap"
                )
            }
        }
    }

    func testBackRegions() throws {
        for gender in BodyGender.allCases {
            let view = BodyView(gender: gender, side: .back)
                .showSubGroups()
                .highlight(.upperTrapezius, color: Self.orange)
                .highlight(.rhomboids, color: Self.red)
                .highlight(.lowerTrapezius, color: Self.purple)
                .highlight(.rearDeltoid, color: Self.blue)
                .highlight(.rotatorCuff, color: Self.teal)
            try assertSnapshot(view, named: "\(gender.rawValue)_back_regions")
        }
    }

    func testFrontSubGroups() throws {
        for gender in BodyGender.allCases {
            let view = BodyView(gender: gender, side: .front)
                .showSubGroups()
                .highlight(.upperChest, color: Self.red)
                .highlight(.lowerChest, color: Self.orange)
                .highlight(.frontDeltoid, color: Self.purple)
                .highlight(.upperAbs, color: Self.yellow)
                .highlight(.lowerAbs, color: Self.teal)
                .highlight(.serratus, color: Self.red)
                .highlight(.hipFlexors, color: Self.teal)
                .highlight(.innerQuad, color: Self.blue)
                .highlight(.outerQuad, color: Self.purple)
            try assertSnapshot(view, named: "\(gender.rawValue)_front_subgroups")
        }
    }

    // MARK: - Helpers

    private func assertSnapshot<V: View>(_ view: V, named name: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let content = view
            .frame(width: size.width, height: size.height)
            .background(Color.white)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        let actual = try XCTUnwrap(renderer.cgImage, "could not render \(name)", file: file, line: line)
        let referenceURL = Self.snapshotDirectory.appendingPathComponent("\(name).png")

        if ProcessInfo.processInfo.environment["MUSCLEMAP_RECORD_SNAPSHOTS"] != nil {
            try FileManager.default.createDirectory(at: Self.snapshotDirectory, withIntermediateDirectories: true)
            try Self.writePNG(actual, to: referenceURL)
            return
        }

        guard let source = CGImageSourceCreateWithURL(referenceURL as CFURL, nil),
              let reference = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            XCTFail("Missing reference \(referenceURL.lastPathComponent). Record it with MUSCLEMAP_RECORD_SNAPSHOTS=1.", file: file, line: line)
            return
        }

        let actualPixels = Self.rgba(actual, width: Int(size.width), height: Int(size.height))
        let referencePixels = Self.rgba(reference, width: Int(size.width), height: Int(size.height))
        var different = 0
        for pixel in stride(from: 0, to: actualPixels.count, by: 4) {
            for channel in 0..<4 where abs(Int(actualPixels[pixel + channel]) - Int(referencePixels[pixel + channel])) > channelTolerance {
                different += 1
                break
            }
        }
        let fraction = Double(different) / Double(actualPixels.count / 4)
        if fraction > maxDifferentFraction {
            let failureDirectory = ProcessInfo.processInfo.environment["MUSCLEMAP_SNAPSHOT_FAILURES"]
                .map { URL(fileURLWithPath: $0) } ?? FileManager.default.temporaryDirectory
            try? FileManager.default.createDirectory(at: failureDirectory, withIntermediateDirectories: true)
            let failureURL = failureDirectory.appendingPathComponent("\(name)_actual.png")
            try? Self.writePNG(actual, to: failureURL)
            XCTFail(
                "\(name): \(different) pixels differ (\(String(format: "%.2f", fraction * 100))%). Actual image: \(failureURL.path)",
                file: file, line: line
            )
        }
    }

    private static var snapshotDirectory: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("__Snapshots__")
    }

    private static func rgba(_ image: CGImage, width: Int, height: Int) -> [UInt8] {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        pixels.withUnsafeMutableBytes { buffer in
            let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
            context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return pixels
    }

    private static func writePNG(_ image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
    }
}
