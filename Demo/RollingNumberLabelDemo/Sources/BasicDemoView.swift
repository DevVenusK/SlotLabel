//
//  BasicDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI

struct BasicDemoView: View {
    @State private var number: Int = 1000

    private var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            RollingNumberLabelView(
                text: formattedNumber,
                font: .monospacedDigitSystemFont(ofSize: 48, weight: .bold),
                color: .label
            )
            .accessibilityIdentifier("basicNumberLabel")

            Spacer()

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button("-100") {
                        number = max(0, number - 100)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("decreaseBy100")

                    Button("-10") {
                        number = max(0, number - 10)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("decreaseBy10")

                    Button("+10") {
                        number += 10
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("increaseBy10")

                    Button("+100") {
                        number += 100
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("increaseBy100")
                }

                HStack(spacing: 20) {
                    Button("Random") {
                        number = Int.random(in: 0...999999)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("randomButton")

                    Button("Reset") {
                        number = 1000
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("resetButton")
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Basic Demo")
    }
}

#Preview {
    NavigationStack {
        BasicDemoView()
    }
}
