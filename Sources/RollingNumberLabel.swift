//
//  RollingNumberLabel.swift
//  SlotLabel
//
//  Created on 2026-02-02.
//

import UIKit

/// A label that animates number changes with a rolling (slot machine) effect.
/// Only changed digits roll upward while unchanged characters remain static.
public class RollingNumberLabel: UIView {

    // MARK: - Public Properties

    /// The duration of the rolling animation
    public var animationDuration: TimeInterval = 0.3

    /// The timing function for the animation
    public var animationTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    /// Current attributed string value
    public private(set) var attributedText: NSAttributedString?

    // MARK: - Private Properties

    private var characterContainers: [CharacterContainer] = []
    private var currentText: String = ""

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        clipsToBounds = true
    }

    // MARK: - Public Methods

    /// Sets the attributed text without animation
    /// - Parameter attributedText: The attributed string to display
    public func setAttributedText(_ attributedText: NSAttributedString) {
        setAttributedText(attributedText, animated: false)
    }

    /// Sets the attributed text with optional rolling animation
    /// - Parameters:
    ///   - attributedText: The attributed string to display
    ///   - animated: Whether to animate changed digits
    public func setAttributedText(_ attributedText: NSAttributedString, animated: Bool) {
        let newText = attributedText.string
        let oldText = currentText

        self.attributedText = attributedText
        self.currentText = newText

        if animated && !oldText.isEmpty {
            animateTransition(from: oldText, to: newText, attributedText: attributedText)
        } else {
            rebuildCharacters(with: attributedText)
        }
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCharacters()
    }

    public override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        return attributedText.size()
    }

    // MARK: - Private Methods

    private func rebuildCharacters(with attributedText: NSAttributedString) {
        // Remove existing containers
        characterContainers.forEach { $0.removeFromSuperview() }
        characterContainers.removeAll()

        let string = attributedText.string

        for (index, character) in string.enumerated() {
            let range = NSRange(location: index, length: 1)
            let charAttributedString = attributedText.attributedSubstring(from: range)

            let container = CharacterContainer()
            container.setCharacter(charAttributedString)
            addSubview(container)
            characterContainers.append(container)
        }

        layoutCharacters()
        invalidateIntrinsicContentSize()
    }

    private func layoutCharacters() {
        var xOffset: CGFloat = 0

        for container in characterContainers {
            let size = container.characterSize
            container.frame = CGRect(x: xOffset, y: 0, width: size.width, height: bounds.height)
            xOffset += size.width
        }
    }

    private func animateTransition(from oldText: String, to newText: String, attributedText: NSAttributedString) {
        let oldChars = Array(oldText)
        let newChars = Array(newText)

        // Find the alignment point (from the end, typically for currency)
        let changes = calculateChanges(oldChars: oldChars, newChars: newChars)

        // Rebuild containers for new text
        let oldContainers = characterContainers
        characterContainers.removeAll()

        for (index, character) in newText.enumerated() {
            let range = NSRange(location: index, length: 1)
            let charAttributedString = attributedText.attributedSubstring(from: range)

            let container = CharacterContainer()
            container.setCharacter(charAttributedString)
            addSubview(container)
            characterContainers.append(container)
        }

        layoutCharacters()
        invalidateIntrinsicContentSize()

        // Animate changes
        for (newIndex, change) in changes {
            guard newIndex < characterContainers.count else { continue }
            let container = characterContainers[newIndex]

            switch change {
            case .changed(let oldChar, let newChar):
                if oldChar.isNumber && newChar.isNumber {
                    // Rolling animation for number changes
                    animateRolling(container: container, from: oldChar, to: newChar)
                } else {
                    // Fade animation for non-number changes
                    animateFade(container: container)
                }
            case .inserted:
                // Fade in for inserted characters
                animateFadeIn(container: container)
            case .unchanged:
                // No animation needed
                break
            }
        }

        // Remove old containers after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            oldContainers.forEach { $0.removeFromSuperview() }
        }
    }

    private enum CharacterChange {
        case unchanged
        case changed(old: Character, new: Character)
        case inserted
    }

    private func calculateChanges(oldChars: [Character], newChars: [Character]) -> [(Int, CharacterChange)] {
        var changes: [(Int, CharacterChange)] = []

        // Align from the end (right-to-left) for currency formatting
        let oldReversed = Array(oldChars.reversed())
        let newReversed = Array(newChars.reversed())

        var oldIndex = 0
        var newIndex = 0
        var resultChanges: [(Int, CharacterChange)] = []

        // Match characters from the end
        while newIndex < newReversed.count {
            let newChar = newReversed[newIndex]

            if oldIndex < oldReversed.count {
                let oldChar = oldReversed[oldIndex]

                // Skip non-digit separators (like commas) for alignment
                if !newChar.isNumber && !oldChar.isNumber {
                    if newChar == oldChar {
                        resultChanges.append((newReversed.count - 1 - newIndex, .unchanged))
                    } else {
                        resultChanges.append((newReversed.count - 1 - newIndex, .changed(old: oldChar, new: newChar)))
                    }
                    oldIndex += 1
                    newIndex += 1
                } else if newChar.isNumber && oldChar.isNumber {
                    if newChar == oldChar {
                        resultChanges.append((newReversed.count - 1 - newIndex, .unchanged))
                    } else {
                        resultChanges.append((newReversed.count - 1 - newIndex, .changed(old: oldChar, new: newChar)))
                    }
                    oldIndex += 1
                    newIndex += 1
                } else if !newChar.isNumber {
                    // New separator, old is number - skip new
                    resultChanges.append((newReversed.count - 1 - newIndex, .inserted))
                    newIndex += 1
                } else {
                    // New is number, old is separator - skip old
                    oldIndex += 1
                }
            } else {
                // No more old characters, all new are inserted
                resultChanges.append((newReversed.count - 1 - newIndex, .inserted))
                newIndex += 1
            }
        }

        return resultChanges
    }

    private func animateRolling(container: CharacterContainer, from oldChar: Character, to newChar: Character) {
        guard let oldValue = Int(String(oldChar)),
              let newValue = Int(String(newChar)) else { return }

        // Determine direction: always roll up (new value slides in from bottom)
        container.animateRollingUp(
            from: String(oldChar),
            to: String(newChar),
            duration: animationDuration,
            timingFunction: animationTimingFunction
        )
    }

    private func animateFade(container: CharacterContainer) {
        container.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            container.alpha = 1
        }
    }

    private func animateFadeIn(container: CharacterContainer) {
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: -10)
        UIView.animate(withDuration: animationDuration) {
            container.alpha = 1
            container.transform = .identity
        }
    }
}

// MARK: - CharacterContainer

private class CharacterContainer: UIView {

    private let currentLabel = UILabel()
    private let animatingLabel = UILabel()

    var characterSize: CGSize {
        return currentLabel.intrinsicContentSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        clipsToBounds = true

        addSubview(currentLabel)
        addSubview(animatingLabel)

        animatingLabel.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        currentLabel.frame = bounds
        animatingLabel.frame = bounds
    }

    func setCharacter(_ attributedString: NSAttributedString) {
        currentLabel.attributedText = attributedString
        currentLabel.sizeToFit()
    }

    func animateRollingUp(from oldValue: String, to newValue: String, duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
        guard let currentAttributedText = currentLabel.attributedText else { return }

        // Create attributed string for old value with same attributes
        let attributes = currentAttributedText.attributes(at: 0, effectiveRange: nil)
        let oldAttributedString = NSAttributedString(string: oldValue, attributes: attributes)

        // Setup animating label with old value at current position
        animatingLabel.attributedText = oldAttributedString
        animatingLabel.frame = bounds
        animatingLabel.isHidden = false

        // Position current label (with new value) below
        currentLabel.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height)

        // Animate: old goes up and out, new comes up from bottom
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: duration, animations: {
            // Old value moves up and out
            self.animatingLabel.frame = CGRect(
                x: 0,
                y: -self.bounds.height,
                width: self.bounds.width,
                height: self.bounds.height
            )

            // New value moves up to center
            self.currentLabel.frame = self.bounds
        }) { _ in
            self.animatingLabel.isHidden = true
            self.animatingLabel.frame = self.bounds
        }

        CATransaction.commit()
    }
}
