//
//  RollingNumberLabel.swift
//  SlotLabel
//
//  Created on 2026-02-02.
//

import UIKit

/// A label that animates number changes with a rolling (slot machine) effect.
/// Only changed digits roll upward while unchanged characters remain static.
/// Supports digit count changes with smooth enter/exit animations.
public class RollingNumberLabel: UIView {

    // MARK: - Public Properties

    /// The duration of the rolling animation
    public var animationDuration: TimeInterval = 0.3

    /// The timing function for the animation
    public var animationTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    /// Current attributed string value
    public private(set) var attributedText: NSAttributedString?

    /// Previous attributed string for animation reference
    private var previousAttributedText: NSAttributedString?

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
        let oldAttributedText = self.attributedText

        self.previousAttributedText = self.attributedText
        self.attributedText = attributedText
        self.currentText = newText

        if animated && !oldText.isEmpty && oldAttributedText != nil {
            animateTransition(
                from: oldText,
                to: newText,
                oldAttributedText: oldAttributedText!,
                newAttributedText: attributedText
            )
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
        characterContainers.forEach { $0.removeFromSuperview() }
        characterContainers.removeAll()

        let string = attributedText.string

        for (index, _) in string.enumerated() {
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

    // MARK: - Animation

    private func animateTransition(
        from oldText: String,
        to newText: String,
        oldAttributedText: NSAttributedString,
        newAttributedText: NSAttributedString
    ) {
        // Extract digit indices and map them
        let oldDigitInfo = extractDigitInfo(from: oldText)
        let newDigitInfo = extractDigitInfo(from: newText)

        // Create mapping between old and new positions based on digit alignment (right-to-left)
        let mapping = createDigitMapping(oldInfo: oldDigitInfo, newInfo: newDigitInfo)

        // Store old containers for exit animation
        let oldContainers = characterContainers
        let oldContainerFrames = oldContainers.map { $0.frame }

        // Create new containers
        characterContainers.removeAll()
        for (index, _) in newText.enumerated() {
            let range = NSRange(location: index, length: 1)
            let charAttributedString = newAttributedText.attributedSubstring(from: range)

            let container = CharacterContainer()
            container.setCharacter(charAttributedString)
            addSubview(container)
            characterContainers.append(container)
        }

        // Calculate new layout positions
        var newPositions: [CGRect] = []
        var xOffset: CGFloat = 0
        for container in characterContainers {
            let size = container.characterSize
            let frame = CGRect(x: xOffset, y: 0, width: size.width, height: bounds.height)
            newPositions.append(frame)
            xOffset += size.width
        }

        // Apply animations based on mapping
        for (newIndex, container) in characterContainers.enumerated() {
            let targetFrame = newPositions[newIndex]
            let newChar = Array(newText)[newIndex]

            if let oldIndex = mapping.newToOld[newIndex] {
                // This position has a corresponding old position
                let oldChar = Array(oldText)[oldIndex]
                let oldFrame = oldContainerFrames[oldIndex]

                if newChar == oldChar {
                    // Same character - just animate position change if needed
                    container.frame = oldFrame
                    container.alpha = 1
                    UIView.animate(withDuration: animationDuration) {
                        container.frame = targetFrame
                    }
                } else if newChar.isNumber && oldChar.isNumber {
                    // Different digit - rolling animation
                    container.frame = targetFrame
                    container.animateRollingUp(
                        from: String(oldChar),
                        to: String(newChar),
                        duration: animationDuration,
                        timingFunction: animationTimingFunction
                    )
                } else {
                    // Non-digit change - crossfade
                    container.frame = targetFrame
                    container.alpha = 0
                    UIView.animate(withDuration: animationDuration) {
                        container.alpha = 1
                    }
                }
            } else {
                // New character - enter animation
                container.frame = targetFrame
                animateEnter(container: container)
            }
        }

        // Animate exit for old containers that don't map to new positions
        for (oldIndex, oldContainer) in oldContainers.enumerated() {
            if mapping.oldToNew[oldIndex] == nil {
                // This old character is being removed - exit animation
                animateExit(container: oldContainer)
            } else {
                // This container is replaced by new one, just remove it
                oldContainer.removeFromSuperview()
            }
        }

        invalidateIntrinsicContentSize()
    }

    // MARK: - Digit Extraction and Mapping

    private struct DigitInfo {
        let indices: [Int]           // Indices of digits in the string
        let digits: [Character]      // The digit characters
        let nonDigitRanges: [(Int, Character)] // Non-digit positions and characters
    }

    private func extractDigitInfo(from text: String) -> DigitInfo {
        var indices: [Int] = []
        var digits: [Character] = []
        var nonDigits: [(Int, Character)] = []

        for (index, char) in text.enumerated() {
            if char.isNumber {
                indices.append(index)
                digits.append(char)
            } else {
                nonDigits.append((index, char))
            }
        }

        return DigitInfo(indices: indices, digits: digits, nonDigitRanges: nonDigits)
    }

    private struct PositionMapping {
        var oldToNew: [Int: Int] = [:]  // old index -> new index
        var newToOld: [Int: Int] = [:]  // new index -> old index
    }

    private func createDigitMapping(oldInfo: DigitInfo, newInfo: DigitInfo) -> PositionMapping {
        var mapping = PositionMapping()

        // Align digits from right to left (for currency formatting)
        let oldDigits = oldInfo.indices.reversed().map { $0 }
        let newDigits = newInfo.indices.reversed().map { $0 }

        let oldDigitArray = Array(oldDigits)
        let newDigitArray = Array(newDigits)

        let minCount = min(oldDigitArray.count, newDigitArray.count)

        // Map digits from right to left
        for i in 0..<minCount {
            let oldIdx = oldDigitArray[i]
            let newIdx = newDigitArray[i]
            mapping.oldToNew[oldIdx] = newIdx
            mapping.newToOld[newIdx] = oldIdx
        }

        // Handle non-digit characters (like suffix "원")
        // Match non-digits that appear after all digits
        let oldSuffix = oldInfo.nonDigitRanges.filter { $0.0 > (oldInfo.indices.last ?? -1) }
        let newSuffix = newInfo.nonDigitRanges.filter { $0.0 > (newInfo.indices.last ?? -1) }

        for (i, (newIdx, newChar)) in newSuffix.enumerated() {
            if i < oldSuffix.count {
                let (oldIdx, oldChar) = oldSuffix[i]
                if newChar == oldChar {
                    mapping.oldToNew[oldIdx] = newIdx
                    mapping.newToOld[newIdx] = oldIdx
                }
            }
        }

        return mapping
    }

    // MARK: - Enter/Exit Animations

    private func animateEnter(container: CharacterContainer) {
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: bounds.height * 0.5)

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                container.alpha = 1
                container.transform = .identity
            }
        )
    }

    private func animateExit(container: CharacterContainer) {
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                container.alpha = 0
                container.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height * 0.5)
            },
            completion: { _ in
                container.removeFromSuperview()
            }
        )
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

        currentLabel.textAlignment = .center
        animatingLabel.textAlignment = .center

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

    func animateRollingUp(
        from oldValue: String,
        to newValue: String,
        duration: TimeInterval,
        timingFunction: CAMediaTimingFunction
    ) {
        guard let currentAttributedText = currentLabel.attributedText else { return }

        // Create attributed string for old value with same attributes
        let attributes = currentAttributedText.attributes(at: 0, effectiveRange: nil)
        let oldAttributedString = NSAttributedString(string: oldValue, attributes: attributes)

        // Setup animating label with old value at current position
        animatingLabel.attributedText = oldAttributedString
        animatingLabel.frame = bounds
        animatingLabel.isHidden = false
        animatingLabel.alpha = 1

        // Position current label (with new value) below
        currentLabel.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: bounds.height)
        currentLabel.alpha = 1

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
