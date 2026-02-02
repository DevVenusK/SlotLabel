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
    var numberOfLines: Int = 1
    var lineSpacing: CGFloat = 4.0
    var preferredMaxLayoutWidth: CGFloat = 0

    func makeUIView(context: Context) -> RollingNumberLabel {
        let label = RollingNumberLabel()
        label.animationDuration = animationDuration
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.lineSpacing = lineSpacing
        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: RollingNumberLabel, context: Context) {
        uiView.animationDuration = animationDuration
        uiView.textAlignment = textAlignment
        uiView.numberOfLines = numberOfLines
        uiView.lineSpacing = lineSpacing
        uiView.preferredMaxLayoutWidth = preferredMaxLayoutWidth
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
        textAlignment: NSTextAlignment = .left,
        numberOfLines: Int = 1,
        lineSpacing: CGFloat = 4.0,
        preferredMaxLayoutWidth: CGFloat = 0
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
        self.numberOfLines = numberOfLines
        self.lineSpacing = lineSpacing
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }
}
