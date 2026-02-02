//
//  CustomizationDemoView.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI
import RollingNumberLabel

struct CustomizationDemoView: View {
    @State private var number: Int = 12345
    @State private var animationDuration: Double = 0.3
    @State private var textAlignment: NSTextAlignment = .center
    @State private var fontSize: Double = 32
    @State private var selectedColor: Color = .primary

    private var attributedText: NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let text = formatter.string(from: NSNumber(value: number)) ?? "\(number)"

        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: UIColor(selectedColor)
            ]
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Preview
                VStack {
                    Text("Preview")
                        .font(.headline)

                    RollingNumberLabelView(
                        attributedText: attributedText,
                        animationDuration: animationDuration,
                        textAlignment: textAlignment
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("customizableLabel")
                }
                .padding(.horizontal)

                // Number Control
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number: \(number)")
                        .font(.subheadline)

                    HStack {
                        Button("-1000") { number = max(0, number - 1000) }
                        Button("-100") { number = max(0, number - 100) }
                        Button("+100") { number += 100 }
                        Button("+1000") { number += 1000 }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Divider()

                // Animation Duration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Animation Duration: \(animationDuration, specifier: "%.2f")s")
                        .font(.subheadline)

                    Slider(value: $animationDuration, in: 0.1...1.0, step: 0.05)
                        .accessibilityIdentifier("durationSlider")
                }
                .padding(.horizontal)

                // Text Alignment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text Alignment")
                        .font(.subheadline)

                    Picker("Alignment", selection: $textAlignment) {
                        Text("Left").tag(NSTextAlignment.left)
                        Text("Center").tag(NSTextAlignment.center)
                        Text("Right").tag(NSTextAlignment.right)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("alignmentPicker")
                }
                .padding(.horizontal)

                // Font Size
                VStack(alignment: .leading, spacing: 12) {
                    Text("Font Size: \(Int(fontSize))pt")
                        .font(.subheadline)

                    Slider(value: $fontSize, in: 16...64, step: 2)
                        .accessibilityIdentifier("fontSizeSlider")
                }
                .padding(.horizontal)

                // Color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(.subheadline)

                    HStack(spacing: 16) {
                        ForEach([Color.primary, .red, .blue, .green, .orange], id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == color {
                                        Circle()
                                            .stroke(.primary, lineWidth: 3)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .navigationTitle("Customization")
    }
}

#Preview {
    NavigationStack {
        CustomizationDemoView()
    }
}
