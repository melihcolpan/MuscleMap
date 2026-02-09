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

#Preview {
    ContentView()
}
