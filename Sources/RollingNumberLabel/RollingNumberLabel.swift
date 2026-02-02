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
public final class RollingNumberLabel: UIView {

    // MARK: - Public Properties

    /// The duration of the rolling animation
    public var animationDuration: TimeInterval = 0.3

    /// The timing function for the animation
    public var animationTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

    /// Text alignment within the view bounds
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            setNeedsLayout()
        }
    }

    /// Current attributed string value
    public private(set) var attributedText: NSAttributedString?

    // MARK: - Private Properties

    private var characterContainers: [CharacterContainer] = []
    private var currentText: String = ""
    private var isAnimating: Bool = false
    private var pendingAttributedText: NSAttributedString?
    private var cachedContentSize: CGSize = .zero

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
        isUserInteractionEnabled = false
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
        // If animating, queue the update
        if isAnimating && animated {
            pendingAttributedText = attributedText
            return
        }

        let newText = attributedText.string
        let oldText = currentText
        let oldAttributedText = self.attributedText

        self.attributedText = attributedText
        self.currentText = newText

        // Calculate and cache content size
        updateCachedContentSize()

        if animated && !oldText.isEmpty && oldAttributedText != nil {
            isAnimating = true
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
        return cachedContentSize
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return cachedContentSize
    }

    // MARK: - Private Methods - Content Size

    private func updateCachedContentSize() {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            cachedContentSize = .zero
            invalidateIntrinsicContentSize()
            return
        }

        // Calculate size by measuring each character individually
        // This ensures consistency with actual layout
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0

        let string = attributedText.string
        for (index, _) in string.enumerated() {
            let range = NSRange(location: index, length: 1)
            let charAttributedString = attributedText.attributedSubstring(from: range)
            let charSize = charAttributedString.size()

            totalWidth += ceil(charSize.width)
            maxHeight = max(maxHeight, ceil(charSize.height))
        }

        cachedContentSize = CGSize(width: totalWidth, height: maxHeight)
        invalidateIntrinsicContentSize()
    }

    // MARK: - Private Methods - Character Management

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

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func layoutCharacters() {
        guard !characterContainers.isEmpty else { return }

        let contentWidth = cachedContentSize.width
        let contentHeight = cachedContentSize.height

        // Calculate starting X based on alignment
        let startX: CGFloat
        switch textAlignment {
        case .center:
            startX = (bounds.width - contentWidth) / 2
        case .right:
            startX = bounds.width - contentWidth
        default:
            startX = 0
        }

        // Calculate Y to center vertically
        let effectiveHeight = bounds.height > 0 ? bounds.height : contentHeight
        let startY = (effectiveHeight - contentHeight) / 2

        var xOffset = startX

        for container in characterContainers {
            let size = container.characterSize
            container.frame = CGRect(
                x: xOffset,
                y: startY,
                width: ceil(size.width),
                height: ceil(contentHeight)
            )
            xOffset += ceil(size.width)
        }
    }

    // MARK: - Animation

    private func animateTransition(
        from oldText: String,
        to newText: String,
        oldAttributedText: NSAttributedString,
        newAttributedText: NSAttributedString
    ) {
        let oldChars = Array(oldText)
        let newChars = Array(newText)

        // Extract digit indices and map them
        let oldDigitInfo = extractDigitInfo(from: oldChars)
        let newDigitInfo = extractDigitInfo(from: newChars)

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
        let newPositions = calculateCharacterPositions()
        let animationHeight = cachedContentSize.height

        // Apply animations based on mapping
        for (newIndex, container) in characterContainers.enumerated() {
            let targetFrame = newPositions[newIndex]
            let newChar = newChars[newIndex]

            if let oldIndex = mapping.newToOld[newIndex] {
                // This position has a corresponding old position
                let oldChar = oldChars[oldIndex]
                let oldFrame = oldContainerFrames[oldIndex]

                if newChar == oldChar {
                    // Same character - just animate position change if needed
                    container.frame = oldFrame
                    container.alpha = 1

                    if oldFrame != targetFrame {
                        UIView.animate(withDuration: animationDuration) {
                            container.frame = targetFrame
                        }
                    }
                } else if newChar.isNumber && oldChar.isNumber {
                    // Different digit - rolling animation
                    container.frame = targetFrame
                    container.animateRollingUp(
                        from: String(oldChar),
                        to: String(newChar),
                        duration: animationDuration,
                        timingFunction: animationTimingFunction,
                        height: animationHeight
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
                animateEnter(container: container, height: animationHeight)
            }
        }

        // Animate exit for old containers that don't map to new positions
        for (oldIndex, oldContainer) in oldContainers.enumerated() {
            if mapping.oldToNew[oldIndex] == nil {
                // This old character is being removed - exit animation
                animateExit(container: oldContainer, height: animationHeight)
            } else {
                // This container is replaced by new one, just remove it
                oldContainer.removeFromSuperview()
            }
        }

        // Complete animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.05) { [weak self] in
            self?.animationDidComplete()
        }
    }

    private func calculateCharacterPositions() -> [CGRect] {
        let contentWidth = cachedContentSize.width
        let contentHeight = cachedContentSize.height

        // Calculate starting X based on alignment
        let startX: CGFloat
        switch textAlignment {
        case .center:
            startX = (bounds.width - contentWidth) / 2
        case .right:
            startX = bounds.width - contentWidth
        default:
            startX = 0
        }

        // Calculate Y to center vertically
        let effectiveHeight = bounds.height > 0 ? bounds.height : contentHeight
        let startY = (effectiveHeight - contentHeight) / 2

        var positions: [CGRect] = []
        var xOffset = startX

        for container in characterContainers {
            let size = container.characterSize
            let frame = CGRect(
                x: xOffset,
                y: startY,
                width: ceil(size.width),
                height: ceil(contentHeight)
            )
            positions.append(frame)
            xOffset += ceil(size.width)
        }

        return positions
    }

    private func animationDidComplete() {
        isAnimating = false

        // Process pending update if any
        if let pending = pendingAttributedText {
            pendingAttributedText = nil
            setAttributedText(pending, animated: true)
        }
    }

    // MARK: - Digit Extraction and Mapping

    private struct DigitInfo {
        let indices: [Int]
        let digits: [Character]
        let nonDigitRanges: [(Int, Character)]
    }

    private func extractDigitInfo(from chars: [Character]) -> DigitInfo {
        var indices: [Int] = []
        var digits: [Character] = []
        var nonDigits: [(Int, Character)] = []

        for (index, char) in chars.enumerated() {
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
        var oldToNew: [Int: Int] = [:]
        var newToOld: [Int: Int] = [:]
    }

    private func createDigitMapping(oldInfo: DigitInfo, newInfo: DigitInfo) -> PositionMapping {
        var mapping = PositionMapping()

        // Align digits from right to left (for currency formatting)
        let oldDigitIndices = Array(oldInfo.indices.reversed())
        let newDigitIndices = Array(newInfo.indices.reversed())

        let minCount = min(oldDigitIndices.count, newDigitIndices.count)

        // Map digits from right to left
        for i in 0..<minCount {
            let oldIdx = oldDigitIndices[i]
            let newIdx = newDigitIndices[i]
            mapping.oldToNew[oldIdx] = newIdx
            mapping.newToOld[newIdx] = oldIdx
        }

        // Handle non-digit characters (like suffix "원")
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

    private func animateEnter(container: CharacterContainer, height: CGFloat) {
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: height * 0.5)

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

    private func animateExit(container: CharacterContainer, height: CGFloat) {
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                container.alpha = 0
                container.transform = CGAffineTransform(translationX: 0, y: -height * 0.5)
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
    private var cachedSize: CGSize = .zero

    var characterSize: CGSize {
        return cachedSize
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
        isUserInteractionEnabled = false

        currentLabel.textAlignment = .center
        animatingLabel.textAlignment = .center

        addSubview(animatingLabel)
        addSubview(currentLabel)

        animatingLabel.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Only update if not animating
        if animatingLabel.isHidden {
            currentLabel.frame = bounds
        }
    }

    func setCharacter(_ attributedString: NSAttributedString) {
        currentLabel.attributedText = attributedString
        cachedSize = attributedString.size()
        cachedSize.width = ceil(cachedSize.width)
        cachedSize.height = ceil(cachedSize.height)
    }

    func animateRollingUp(
        from oldValue: String,
        to newValue: String,
        duration: TimeInterval,
        timingFunction: CAMediaTimingFunction,
        height: CGFloat
    ) {
        guard let currentAttributedText = currentLabel.attributedText,
              currentAttributedText.length > 0 else { return }

        // Create attributed string for old value with same attributes
        let attributes = currentAttributedText.attributes(at: 0, effectiveRange: nil)
        let oldAttributedString = NSAttributedString(string: oldValue, attributes: attributes)

        // Setup animating label with old value at current position
        animatingLabel.attributedText = oldAttributedString
        animatingLabel.frame = bounds
        animatingLabel.isHidden = false
        animatingLabel.alpha = 1

        // Position current label (with new value) below
        currentLabel.frame = CGRect(x: 0, y: height, width: bounds.width, height: height)
        currentLabel.alpha = 1

        // Animate: old goes up and out, new comes up from bottom
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)

        UIView.animate(withDuration: duration, animations: {
            // Old value moves up and out
            self.animatingLabel.frame = CGRect(
                x: 0,
                y: -height,
                width: self.bounds.width,
                height: height
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
