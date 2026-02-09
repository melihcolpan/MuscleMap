import SwiftUI
import MuscleMap

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HighlightDemo()
                .tabItem { Label("Highlight", systemImage: "figure.stand") }
                .tag(0)

            HeatmapDemo()
                .tabItem { Label("Heatmap", systemImage: "flame") }
                .tag(1)

            InteractiveDemo()
                .tabItem { Label("Interactive", systemImage: "hand.tap") }
                .tag(2)

            StyleDemo()
                .tabItem { Label("Styles", systemImage: "paintbrush") }
                .tag(3)

            GradientDemo()
                .tabItem { Label("Gradient", systemImage: "paintpalette") }
                .tag(4)

            AnimationDemo()
                .tabItem { Label("Animation", systemImage: "wand.and.stars") }
                .tag(5)

            InteractiveV2Demo()
                .tabItem { Label("Interactive V2", systemImage: "hand.draw") }
                .tag(6)
        }
    }
}

// MARK: - Highlight Demo

struct HighlightDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Male - Front & Back")
                        .font(.headline)

                    HStack(spacing: 16) {
                        BodyView(gender: .male, side: .front)
                            .highlight(.chest, color: .red)
                            .highlight(.biceps, color: .orange, opacity: 0.8)
                            .highlight(.abs, color: .yellow, opacity: 0.6)
                            .highlight(.quadriceps, color: .red)
                            .highlight(.deltoids, color: .orange)
                            .frame(height: 350)

                        BodyView(gender: .male, side: .back)
                            .highlight(.trapezius, color: .orange)
                            .highlight(.upperBack, color: .red)
                            .highlight(.lowerBack, color: .yellow)
                            .highlight(.hamstring, color: .red)
                            .highlight(.gluteal, color: .orange)
                            .frame(height: 350)
                    }
                    .padding(.horizontal)

                    Text("Female - Front & Back")
                        .font(.headline)

                    HStack(spacing: 16) {
                        BodyView(gender: .female, side: .front)
                            .highlight(.chest, color: .pink)
                            .highlight(.abs, color: .orange)
                            .highlight(.quadriceps, color: .red)
                            .highlight(.calves, color: .yellow)
                            .frame(height: 350)

                        BodyView(gender: .female, side: .back)
                            .highlight(.gluteal, color: .pink)
                            .highlight(.hamstring, color: .red)
                            .highlight(.upperBack, color: .orange)
                            .frame(height: 350)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Highlight")
        }
    }
}

// MARK: - Heatmap Demo

struct HeatmapDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Workout Intensity (0-4)")
                        .font(.headline)

                    BodyView(gender: .male, side: .front)
                        .intensities([
                            .chest: 4,
                            .biceps: 3,
                            .abs: 2,
                            .quadriceps: 4,
                            .deltoids: 3,
                            .forearm: 1,
                            .obliques: 2,
                            .triceps: 2
                        ])
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Thermal Scale")
                        .font(.headline)

                    BodyView(gender: .male, side: .back)
                        .intensities([
                            .trapezius: 3,
                            .upperBack: 4,
                            .lowerBack: 2,
                            .hamstring: 3,
                            .gluteal: 4,
                            .calves: 1,
                            .triceps: 2
                        ], colorScale: .thermal)
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Medical Scale")
                        .font(.headline)

                    let data: [MuscleIntensity] = [
                        .init(muscle: .chest, intensity: 0.9),
                        .init(muscle: .deltoids, intensity: 0.7),
                        .init(muscle: .biceps, intensity: 0.5),
                        .init(muscle: .abs, intensity: 0.3),
                        .init(muscle: .quadriceps, intensity: 0.6)
                    ]

                    BodyView(gender: .female, side: .front)
                        .heatmap(data, colorScale: .medical)
                        .frame(height: 400)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Heatmap")
        }
    }
}

// MARK: - Interactive Demo

struct InteractiveDemo: View {
    @State private var selectedMuscle: Muscle?
    @State private var selectedSide: MuscleSide = .both
    @State private var gender: BodyGender = .male
    @State private var bodySide: BodySide = .front

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(BodyGender.male)
                        Text("Female").tag(BodyGender.female)
                    }
                    .pickerStyle(.segmented)

                    Picker("Side", selection: $bodySide) {
                        Text("Front").tag(BodySide.front)
                        Text("Back").tag(BodySide.back)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                if let muscle = selectedMuscle {
                    HStack {
                        Image(systemName: "figure.stand")
                        Text("\(muscle.displayName) (\(selectedSide.rawValue))")
                            .font(.title3.bold())
                    }
                    .padding(8)
                    .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("Tap a muscle")
                        .foregroundStyle(.secondary)
                }

                BodyView(gender: gender, side: bodySide)
                    .selected(selectedMuscle)
                    .pulseSelected()
                    .onMuscleSelected { muscle, side in
                        selectedMuscle = muscle
                        selectedSide = side
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Interactive")
        }
    }
}

// MARK: - Style Demo

struct StyleDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    styleCard("Default", style: .default)
                    styleCard("Minimal", style: .minimal)
                    styleCard("Neon", style: .neon, background: .black)
                    styleCard("Medical", style: .medical)
                }
                .padding()
            }
            .navigationTitle("Styles")
        }
    }

    @ViewBuilder
    func styleCard(_ name: String, style: BodyViewStyle, background: Color = .clear) -> some View {
        VStack {
            Text(name)
                .font(.headline)

            BodyView(gender: .male, side: .front)
                .highlight(.chest, color: .red)
                .highlight(.biceps, color: .orange)
                .highlight(.quadriceps, color: .red)
                .bodyStyle(style)
                .frame(height: 300)
                .padding()
                .background(background, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Gradient Demo

struct GradientDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Linear Gradient")
                        .font(.headline)

                    BodyView(gender: .male, side: .front)
                        .highlight(.chest, linearGradient: [.red, .orange], startPoint: .top, endPoint: .bottom)
                        .highlight(.biceps, linearGradient: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        .highlight(.abs, linearGradient: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                        .highlight(.quadriceps, linearGradient: [.purple, .pink])
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Radial Gradient")
                        .font(.headline)

                    BodyView(gender: .male, side: .front)
                        .highlight(.chest, radialGradient: [.white, .red], center: .center, endRadius: 40)
                        .highlight(.biceps, radialGradient: [.white, .blue], center: .center, endRadius: 30)
                        .highlight(.deltoids, radialGradient: [.yellow, .orange], center: .center, endRadius: 25)
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Mixed Fills")
                        .font(.headline)

                    BodyView(gender: .female, side: .front)
                        .highlight(.chest, linearGradient: [.pink, .red])
                        .highlight(.abs, color: .orange, opacity: 0.7)
                        .highlight(.quadriceps, radialGradient: [.white, .purple], center: .center, endRadius: 50)
                        .frame(height: 400)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Gradient")
        }
    }
}

// MARK: - Animation Demo

struct AnimationDemo: View {
    @State private var showUpperBody = true
    @State private var selectedMuscle: Muscle?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Animated Transitions")
                        .font(.headline)

                    Button(showUpperBody ? "Show Lower Body" : "Show Upper Body") {
                        showUpperBody.toggle()
                    }
                    .buttonStyle(.borderedProminent)

                    animatedBodyView
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Pulse Animation")
                        .font(.headline)

                    Text("Tap a muscle to see pulse effect")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    BodyView(gender: .male, side: .front)
                        .highlight(.chest, linearGradient: [.red, .orange])
                        .highlight(.biceps, color: .blue)
                        .highlight(.quadriceps, color: .purple)
                        .selected(selectedMuscle)
                        .pulseSelected(speed: 1.5, range: 0.6...1.0)
                        .onMuscleSelected { muscle, _ in
                            selectedMuscle = muscle
                        }
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text("Shadow + Neon Style")
                        .font(.headline)

                    BodyView(gender: .male, side: .front)
                        .highlight(.chest, linearGradient: [.cyan, .blue])
                        .highlight(.biceps, color: .cyan)
                        .highlight(.quadriceps, linearGradient: [.cyan, .teal])
                        .bodyStyle(.neon)
                        .frame(height: 400)
                        .padding(.horizontal)
                        .background(.black, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Animation")
        }
    }

    @ViewBuilder
    private var animatedBodyView: some View {
        if showUpperBody {
            BodyView(gender: .male, side: .front)
                .highlight(.chest, color: .red)
                .highlight(.biceps, color: .orange)
                .highlight(.deltoids, color: .yellow)
                .highlight(.abs, color: .red, opacity: 0.6)
                .animated(duration: 0.5)
        } else {
            BodyView(gender: .male, side: .front)
                .highlight(.quadriceps, color: .blue)
                .highlight(.calves, color: .cyan)
                .highlight(.hamstring, color: .purple)
                .animated(duration: 0.5)
        }
    }
}

// MARK: - Interactive V2 Demo

struct InteractiveV2Demo: View {
    @State private var selectedMuscles: Set<Muscle> = []
    @State private var lastSide: MuscleSide = .both
    @State private var longPressedMuscle: String = ""
    @State private var history = SelectionHistory()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Status bar
                HStack {
                    if selectedMuscles.isEmpty {
                        Text("Tap to select, long press for info, drag to paint")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(selectedMuscles.map(\.displayName).sorted().joined(separator: ", "))
                            .font(.caption.bold())
                            .lineLimit(2)
                    }
                    Spacer()
                    Button("Undo") {
                        if let state = history.undo() {
                            selectedMuscles = state
                        }
                    }
                    .disabled(!history.canUndo)

                    Button("Redo") {
                        if let state = history.redo() {
                            selectedMuscles = state
                        }
                    }
                    .disabled(!history.canRedo)
                }
                .padding(.horizontal)

                if !longPressedMuscle.isEmpty {
                    Text(longPressedMuscle)
                        .font(.footnote)
                        .padding(6)
                        .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                        .transition(.opacity)
                }

                // Body view with all interactive features
                BodyView(gender: .male, side: .front)
                    .highlight(Array(selectedMuscles), color: .orange)
                    .selected(selectedMuscles)
                    .pulseSelected(speed: 1.5, range: 0.7...1.0)
                    .onMuscleSelected { muscle, side in
                        var newSelection = selectedMuscles
                        if newSelection.contains(muscle) {
                            newSelection.remove(muscle)
                        } else {
                            newSelection.insert(muscle)
                        }
                        selectedMuscles = newSelection
                        lastSide = side
                        history.push(newSelection)
                    }
                    .onMuscleLongPressed(duration: 0.5) { muscle, side in
                        withAnimation {
                            longPressedMuscle = "Long pressed: \(muscle.displayName) (\(side.rawValue))"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { longPressedMuscle = "" }
                        }
                    }
                    .onMuscleDragged({ muscle, side in
                        if !selectedMuscles.contains(muscle) {
                            selectedMuscles.insert(muscle)
                            history.push(selectedMuscles)
                        }
                    }, onEnded: {})
                    .zoomable(minScale: 1.0, maxScale: 3.0)
                    .tooltip { muscle, _ in
                        Text(muscle.displayName)
                            .font(.caption2.bold())
                            .padding(4)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                    }
                    .undoable(history)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)

                Button("Clear Selection") {
                    selectedMuscles.removeAll()
                    history.push(selectedMuscles)
                }
                .buttonStyle(.bordered)
                .disabled(selectedMuscles.isEmpty)
            }
            .padding(.vertical)
            .navigationTitle("Interactive V2")
        }
    }
}

#Preview {
    ContentView()
}
