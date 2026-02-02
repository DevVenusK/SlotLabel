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
    private var containerPool: [CharacterContainer] = []
    private var currentText: String = ""
    private var isAnimating: Bool = false
    private var pendingAttributedText: NSAttributedString?
    private var cachedContentSize: CGSize = .zero
    private var characterSizeCache: [CharacterCacheKey: CGSize] = [:]

    private struct CharacterCacheKey: Hashable {
        let character: String
        let fontName: String
        let fontSize: CGFloat
    }

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
        layer.drawsAsynchronously = true
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

        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0

        let string = attributedText.string
        for (index, char) in string.enumerated() {
            let charSize = getCharacterSize(at: index, in: attributedText, character: char)
            totalWidth += charSize.width
            maxHeight = max(maxHeight, charSize.height)
        }

        cachedContentSize = CGSize(width: totalWidth, height: maxHeight)
        invalidateIntrinsicContentSize()
    }

    private func getCharacterSize(at index: Int, in attributedText: NSAttributedString, character: Character) -> CGSize {
        let range = NSRange(location: index, length: 1)
        let attributes = attributedText.attributes(at: index, effectiveRange: nil)

        // Create cache key
        let font = attributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 17)
        let cacheKey = CharacterCacheKey(
            character: String(character),
            fontName: font.fontName,
            fontSize: font.pointSize
        )

        // Check cache
        if let cachedSize = characterSizeCache[cacheKey] {
            return cachedSize
        }

        // Calculate and cache
        let charAttributedString = attributedText.attributedSubstring(from: range)
        var size = charAttributedString.size()
        size.width = ceil(size.width)
        size.height = ceil(size.height)

        characterSizeCache[cacheKey] = size
        return size
    }

    // MARK: - Private Methods - Container Pool

    private func obtainContainer() -> CharacterContainer {
        if let container = containerPool.popLast() {
            container.prepareForReuse()
            return container
        }
        return CharacterContainer()
    }

    private func recycleContainer(_ container: CharacterContainer) {
        container.removeFromSuperview()
        containerPool.append(container)
    }

    private func recycleContainers(_ containers: [CharacterContainer]) {
        containers.forEach { recycleContainer($0) }
    }

    // MARK: - Private Methods - Character Management

    private func rebuildCharacters(with attributedText: NSAttributedString) {
        // Recycle existing containers
        recycleContainers(characterContainers)
        characterContainers.removeAll()

        let string = attributedText.string

        for (index, _) in string.enumerated() {
            let range = NSRange(location: index, length: 1)
            let charAttributedString = attributedText.attributedSubstring(from: range)

            let container = obtainContainer()
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
                width: size.width,
                height: contentHeight
            )
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
        let oldChars = Array(oldText)
        let newChars = Array(newText)

        // Extract digit indices and map them
        let oldDigitInfo = extractDigitInfo(from: oldChars)
        let newDigitInfo = extractDigitInfo(from: newChars)

        // Create mapping between old and new positions based on digit alignment (right-to-left)
        let mapping = createDigitMapping(oldInfo: oldDigitInfo, newInfo: newDigitInfo)

        // Store old containers and their frames
        let oldContainers = characterContainers
        let oldContainerFrames = oldContainers.map { $0.frame }

        // Prepare new containers array
        var newContainers: [CharacterContainer] = []
        newContainers.reserveCapacity(newChars.count)

        // Calculate positions for new layout
        let newPositions = calculatePositions(for: newAttributedText)
        let animationHeight = cachedContentSize.height

        // Build new containers, reusing where possible
        for (newIndex, _) in newChars.enumerated() {
            let range = NSRange(location: newIndex, length: 1)
            let charAttributedString = newAttributedText.attributedSubstring(from: range)
            let targetFrame = newPositions[newIndex]
            let newChar = newChars[newIndex]

            if let oldIndex = mapping.newToOld[newIndex] {
                let oldChar = oldChars[oldIndex]
                let oldFrame = oldContainerFrames[oldIndex]
                let oldContainer = oldContainers[oldIndex]

                if newChar == oldChar {
                    // Same character - reuse container, animate position if needed
                    oldContainer.setCharacter(charAttributedString)
                    newContainers.append(oldContainer)

                    if oldFrame != targetFrame {
                        UIView.animate(withDuration: animationDuration) {
                            oldContainer.frame = targetFrame
                        }
                    }
                } else if newChar.isNumber && oldChar.isNumber {
                    // Different digit - get new container and animate rolling
                    let container = obtainContainer()
                    container.setCharacter(charAttributedString)
                    container.frame = targetFrame
                    addSubview(container)
                    newContainers.append(container)

                    container.animateRollingUp(
                        from: String(oldChar),
                        to: String(newChar),
                        duration: animationDuration,
                        timingFunction: animationTimingFunction,
                        height: animationHeight
                    )
                } else {
                    // Non-digit change - just slide position (no animation for non-digits)
                    oldContainer.setCharacter(charAttributedString)
                    newContainers.append(oldContainer)

                    if oldFrame != targetFrame {
                        UIView.animate(withDuration: animationDuration) {
                            oldContainer.frame = targetFrame
                        }
                    }
                }
            } else {
                // New character
                let container = obtainContainer()
                container.setCharacter(charAttributedString)
                container.frame = targetFrame
                addSubview(container)
                newContainers.append(container)

                if newChar.isNumber {
                    // New digit - enter animation (slide up from below)
                    animateEnter(container: container, height: animationHeight)
                }
                // Non-digit new characters appear instantly (no animation)
            }
        }

        // Handle old containers that don't map to new positions
        for (oldIndex, oldContainer) in oldContainers.enumerated() {
            if mapping.oldToNew[oldIndex] == nil {
                // This old character is being removed
                let oldChar = oldChars[oldIndex]
                if oldChar.isNumber {
                    // Digit removal - exit animation (slide up and fade out)
                    animateExit(container: oldContainer, height: animationHeight)
                } else {
                    // Non-digit removal - instant removal (no animation)
                    recycleContainer(oldContainer)
                }
            } else {
                // Check if this container was reused
                let wasReused = newContainers.contains { $0 === oldContainer }
                if !wasReused {
                    recycleContainer(oldContainer)
                }
            }
        }

        characterContainers = newContainers

        // Complete animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.05) { [weak self] in
            self?.animationDidComplete()
        }
    }

    private func calculatePositions(for attributedText: NSAttributedString) -> [CGRect] {
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
        positions.reserveCapacity(attributedText.length)
        var xOffset = startX

        let string = attributedText.string
        for (index, char) in string.enumerated() {
            let size = getCharacterSize(at: index, in: attributedText, character: char)
            let frame = CGRect(
                x: xOffset,
                y: startY,
                width: size.width,
                height: contentHeight
            )
            positions.append(frame)
            xOffset += size.width
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

        indices.reserveCapacity(chars.count)
        digits.reserveCapacity(chars.count)

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
        let oldDigitIndices = oldInfo.indices.reversed()
        let newDigitIndices = newInfo.indices.reversed()

        let oldArray = Array(oldDigitIndices)
        let newArray = Array(newDigitIndices)
        let minCount = min(oldArray.count, newArray.count)

        // Map digits from right to left
        for i in 0..<minCount {
            let oldIdx = oldArray[i]
            let newIdx = newArray[i]
            mapping.oldToNew[oldIdx] = newIdx
            mapping.newToOld[newIdx] = oldIdx
        }

        // Map non-digit characters (separators like commas, and suffixes like "원")
        // First, try to match same characters at same positions
        for (oldIdx, oldChar) in oldInfo.nonDigitRanges {
            for (newIdx, newChar) in newInfo.nonDigitRanges {
                if oldIdx == newIdx && oldChar == newChar {
                    if mapping.oldToNew[oldIdx] == nil && mapping.newToOld[newIdx] == nil {
                        mapping.oldToNew[oldIdx] = newIdx
                        mapping.newToOld[newIdx] = oldIdx
                    }
                }
            }
        }

        // Then, try to match remaining same characters by order
        var unmatchedOld = oldInfo.nonDigitRanges.filter { mapping.oldToNew[$0.0] == nil }
        var unmatchedNew = newInfo.nonDigitRanges.filter { mapping.newToOld[$0.0] == nil }

        for (newIdx, newChar) in unmatchedNew {
            if let matchIndex = unmatchedOld.firstIndex(where: { $0.1 == newChar }) {
                let (oldIdx, _) = unmatchedOld[matchIndex]
                mapping.oldToNew[oldIdx] = newIdx
                mapping.newToOld[newIdx] = oldIdx
                unmatchedOld.remove(at: matchIndex)
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
            completion: { [weak self] _ in
                self?.recycleContainer(container)
            }
        )
    }
}

// MARK: - CharacterContainer

private final class CharacterContainer: UIView {

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
        layer.drawsAsynchronously = true

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

    func prepareForReuse() {
        alpha = 1
        transform = .identity
        currentLabel.attributedText = nil
        animatingLabel.attributedText = nil
        animatingLabel.isHidden = true
        layer.shouldRasterize = false
    }

    func setCharacter(_ attributedString: NSAttributedString) {
        currentLabel.attributedText = attributedString
        cachedSize = attributedString.size()
        cachedSize.width = ceil(cachedSize.width)
        cachedSize.height = ceil(cachedSize.height)
    }

    func enableRasterization() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
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
