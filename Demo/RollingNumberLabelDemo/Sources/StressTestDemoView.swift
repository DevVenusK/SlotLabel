//
//  StressTestDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI

struct StressTestDemoView: View {
    @State private var number: Int = 0
    @State private var isRunning: Bool = false
    @State private var updateInterval: Double = 0.1
    @State private var timer: Timer?

    private var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 16) {
                RollingNumberLabelView(
                    text: formattedNumber,
                    font: .monospacedDigitSystemFont(ofSize: 48, weight: .bold),
                    color: isRunning ? .systemGreen : .label,
                    animationDuration: min(updateInterval * 0.8, 0.3)
                )
                .accessibilityIdentifier("stressTestLabel")

                Text(isRunning ? "Running..." : "Stopped")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 20) {
                // Update Interval
                VStack(alignment: .leading, spacing: 8) {
                    Text("Update Interval: \(updateInterval, specifier: "%.2f")s")
                        .font(.subheadline)

                    Slider(value: $updateInterval, in: 0.05...1.0, step: 0.05)
                        .disabled(isRunning)
                        .accessibilityIdentifier("intervalSlider")
                }
                .padding(.horizontal)

                // Control Buttons
                HStack(spacing: 20) {
                    Button(isRunning ? "Stop" : "Start") {
                        toggleTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isRunning ? .red : .green)
                    .accessibilityIdentifier("toggleButton")

                    Button("Reset") {
                        stopTimer()
                        number = 0
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("resetButton")
                }

                // Preset Buttons
                VStack(spacing: 12) {
                    Text("Presets")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Button("Slow (1s)") {
                            updateInterval = 1.0
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)

                        Button("Normal (0.3s)") {
                            updateInterval = 0.3
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)

                        Button("Fast (0.1s)") {
                            updateInterval = 0.1
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Stress Test")
        .onDisappear {
            stopTimer()
        }
    }

    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            let change = Int.random(in: -1000...1000)
            number = max(0, number + change)
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    NavigationStack {
        StressTestDemoView()
    }
}
