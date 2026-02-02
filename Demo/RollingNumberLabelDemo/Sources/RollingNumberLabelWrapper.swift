//
//  RollingNumberLabelWrapper.swift
//  RollingNumberLabelDemo
//
//  Created on 2026-02-02.
//

import SwiftUI
import RollingNumberLabel

/// SwiftUI wrapper for RollingNumberLabel
struct RollingNumberLabelView: UIViewRepresentable {
    let attributedText: NSAttributedString
    var animated: Bool = true
    var animationDuration: TimeInterval = 0.3
    var textAlignment: NSTextAlignment = .left

    func makeUIView(context: Context) -> RollingNumberLabel {
        let label = RollingNumberLabel()
        label.animationDuration = animationDuration
        label.textAlignment = textAlignment
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: RollingNumberLabel, context: Context) {
        uiView.animationDuration = animationDuration
        uiView.textAlignment = textAlignment
        uiView.setAttributedText(attributedText, animated: animated)
    }
}

// MARK: - Convenience Initializers

extension RollingNumberLabelView {
    init(
        text: String,
        font: UIFont = .systemFont(ofSize: 32, weight: .bold),
        color: UIColor = .label,
        animated: Bool = true,
        animationDuration: TimeInterval = 0.3,
        textAlignment: NSTextAlignment = .left
    ) {
        self.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
        self.animated = animated
        self.animationDuration = animationDuration
        self.textAlignment = textAlignment
    }
}
