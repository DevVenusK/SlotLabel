//
//  UILabel+RollingNumber.swift
//  SlotLabel
//
//  Created on 2026-02-02.
//

import UIKit

/// Extension to add rolling number animation capability to standard UILabel
/// by overlaying a RollingNumberLabel on top.
public extension UILabel {

    private enum AssociatedKeys {
        static let rollingOverlay = "rollingOverlay"
        static let previousAttributedText = "previousAttributedText"
    }

    /// The rolling number overlay view (created on demand)
    private var rollingOverlay: RollingNumberLabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rollingOverlay) as? RollingNumberLabel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rollingOverlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Previous attributed text for comparison
    private var previousAttributedText: NSAttributedString? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.previousAttributedText) as? NSAttributedString
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.previousAttributedText, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Sets attributed text with rolling animation for changed digits
    /// - Parameters:
    ///   - attributedText: The new attributed text to display
    ///   - animated: Whether to animate the transition
    ///   - duration: Animation duration (default: 0.3 seconds)
    func setAttributedTextWithRolling(
        _ attributedText: NSAttributedString,
        animated: Bool = true,
        duration: TimeInterval = 0.3
    ) {
        let overlay = getOrCreateOverlay()
        overlay.animationDuration = duration

        // Hide the original label text
        self.attributedText = NSAttributedString(string: "")

        // Set the overlay text
        overlay.setAttributedText(attributedText, animated: animated && previousAttributedText != nil)

        // Store for next comparison
        previousAttributedText = attributedText
    }

    private func getOrCreateOverlay() -> RollingNumberLabel {
        if let existing = rollingOverlay {
            return existing
        }

        let overlay = RollingNumberLabel()
        overlay.translatesAutoresizingMaskIntoConstraints = false

        addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        rollingOverlay = overlay
        return overlay
    }

    /// Removes the rolling number overlay if present
    func removeRollingOverlay() {
        rollingOverlay?.removeFromSuperview()
        rollingOverlay = nil
        previousAttributedText = nil
    }
}
