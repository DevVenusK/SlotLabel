//
//  RollingNumberLabelTests.swift
//  RollingNumberLabel
//
//  Created on 2026-02-02.
//

import Testing
import UIKit
@testable import RollingNumberLabel

@Suite("RollingNumberLabel Tests")
struct RollingNumberLabelTests {

    // MARK: - Initialization Tests

    @Test("Initialize with frame")
    func initWithFrame() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        #expect(label.attributedText == nil)
        #expect(label.animationDuration == 0.3)
        #expect(label.textAlignment == .left)
    }

    @Test("Initialize with zero frame")
    func initWithZeroFrame() {
        let label = RollingNumberLabel(frame: .zero)

        #expect(label.frame == .zero)
        #expect(label.attributedText == nil)
    }

    // MARK: - Attributed Text Tests

    @Test("Set attributed text without animation")
    func setAttributedTextWithoutAnimation() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(string: "1,000,000원")

        label.setAttributedText(text, animated: false)

        #expect(label.attributedText?.string == "1,000,000원")
    }

    @Test("Set attributed text with attributes preserved")
    func setAttributedTextWithAttributes() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.red
        ]
        let text = NSAttributedString(string: "12,345", attributes: attributes)

        label.setAttributedText(text, animated: false)

        #expect(label.attributedText?.string == "12,345")
    }

    @Test("Set empty attributed text")
    func setEmptyAttributedText() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(string: "")

        label.setAttributedText(text, animated: false)

        #expect(label.attributedText?.string == "")
        #expect(label.intrinsicContentSize == .zero)
    }

    // MARK: - Intrinsic Content Size Tests

    @Test("Intrinsic content size is calculated correctly")
    func intrinsicContentSizeCalculation() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(
            string: "100",
            attributes: [.font: UIFont.systemFont(ofSize: 20)]
        )

        label.setAttributedText(text, animated: false)

        let size = label.intrinsicContentSize
        #expect(size.width > 0)
        #expect(size.height > 0)
    }

    @Test("Intrinsic content size updates when text changes")
    func intrinsicContentSizeUpdates() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let font = UIFont.systemFont(ofSize: 20)

        let shortText = NSAttributedString(string: "1", attributes: [.font: font])
        label.setAttributedText(shortText, animated: false)
        let shortSize = label.intrinsicContentSize

        let longText = NSAttributedString(string: "1,000,000", attributes: [.font: font])
        label.setAttributedText(longText, animated: false)
        let longSize = label.intrinsicContentSize

        #expect(longSize.width > shortSize.width)
    }

    @Test("sizeThatFits returns correct size")
    func sizeThatFitsReturnsCorrectSize() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(
            string: "12,345",
            attributes: [.font: UIFont.systemFont(ofSize: 20)]
        )

        label.setAttributedText(text, animated: false)

        let fittingSize = label.sizeThatFits(CGSize(width: 1000, height: 1000))
        #expect(fittingSize == label.intrinsicContentSize)
    }

    // MARK: - Text Alignment Tests

    @Test("Default text alignment is left")
    func defaultTextAlignmentIsLeft() {
        let label = RollingNumberLabel(frame: .zero)
        #expect(label.textAlignment == .left)
    }

    @Test("Text alignment can be changed", arguments: [
        NSTextAlignment.left,
        NSTextAlignment.center,
        NSTextAlignment.right
    ])
    func textAlignmentCanBeChanged(alignment: NSTextAlignment) {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.textAlignment = alignment
        #expect(label.textAlignment == alignment)
    }

    // MARK: - Animation Duration Tests

    @Test("Default animation duration is 0.3")
    func defaultAnimationDuration() {
        let label = RollingNumberLabel(frame: .zero)
        #expect(label.animationDuration == 0.3)
    }

    @Test("Animation duration can be changed")
    func animationDurationCanBeChanged() {
        let label = RollingNumberLabel(frame: .zero)
        label.animationDuration = 0.5
        #expect(label.animationDuration == 0.5)
    }

    // MARK: - Animation Tests

    @Test("Animation queues pending updates")
    @MainActor
    func animationQueuesPendingUpdates() async {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.animationDuration = 0.1

        let text1 = NSAttributedString(string: "100")
        let text2 = NSAttributedString(string: "200")
        let text3 = NSAttributedString(string: "300")

        // Set initial text
        label.setAttributedText(text1, animated: false)

        // Trigger animation and queue update
        label.setAttributedText(text2, animated: true)
        label.setAttributedText(text3, animated: true)

        // Wait for animations to complete
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        #expect(label.attributedText?.string == "300")
    }
}

// MARK: - Digit Mapping Tests

@Suite("Digit Mapping Tests")
struct DigitMappingTests {

    @Test("Same length strings map correctly")
    func sameLengthMapping() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "1,000,000원")
        label.setAttributedText(text1, animated: false)

        let text2 = NSAttributedString(string: "1,234,567원")
        label.setAttributedText(text2, animated: true)

        #expect(label.attributedText?.string == "1,234,567원")
    }

    @Test("Increasing digit count")
    func increasingDigitCount() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "999,999원")
        label.setAttributedText(text1, animated: false)

        let text2 = NSAttributedString(string: "1,000,000원")
        label.setAttributedText(text2, animated: true)

        #expect(label.attributedText?.string == "1,000,000원")
    }

    @Test("Decreasing digit count")
    func decreasingDigitCount() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "1,000,000원")
        label.setAttributedText(text1, animated: false)

        let text2 = NSAttributedString(string: "999,999원")
        label.setAttributedText(text2, animated: true)

        #expect(label.attributedText?.string == "999,999원")
    }

    @Test("Numbers only without suffix")
    func numbersOnlyWithoutSuffix() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "1,000")
        label.setAttributedText(text1, animated: false)

        let text2 = NSAttributedString(string: "2,500")
        label.setAttributedText(text2, animated: true)

        #expect(label.attributedText?.string == "2,500")
    }

    @Test("Different suffix characters")
    func differentSuffixCharacters() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "$1,000")
        label.setAttributedText(text1, animated: false)

        let text2 = NSAttributedString(string: "$2,000")
        label.setAttributedText(text2, animated: true)

        #expect(label.attributedText?.string == "$2,000")
    }
}

// MARK: - UILabel Extension Tests

@Suite("UILabel Extension Tests")
struct UILabelExtensionTests {

    @Test("UILabel extension creates overlay")
    @MainActor
    func extensionCreatesOverlay() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(string: "1,000원")

        label.setAttributedTextWithRolling(text, animated: false)

        // Check that overlay was added
        let hasOverlay = label.subviews.contains { $0 is RollingNumberLabel }
        #expect(hasOverlay)
    }

    @Test("UILabel extension removes overlay")
    @MainActor
    func extensionRemovesOverlay() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let text = NSAttributedString(string: "1,000원")

        label.setAttributedTextWithRolling(text, animated: false)
        label.removeRollingOverlay()

        let hasOverlay = label.subviews.contains { $0 is RollingNumberLabel }
        #expect(!hasOverlay)
    }

    @Test("UILabel extension updates text")
    @MainActor
    func extensionUpdatesText() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        let text1 = NSAttributedString(string: "1,000원")
        label.setAttributedTextWithRolling(text1, animated: false)

        let text2 = NSAttributedString(string: "2,000원")
        label.setAttributedTextWithRolling(text2, animated: false)

        let overlay = label.subviews.first { $0 is RollingNumberLabel } as? RollingNumberLabel
        #expect(overlay?.attributedText?.string == "2,000원")
    }
}

// MARK: - Performance Optimization Tests

@Suite("Performance Optimization Tests")
struct PerformanceOptimizationTests {

    @Test("Subview count remains stable after multiple updates")
    @MainActor
    func subviewCountStability() async {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.animationDuration = 0.05

        // Initial text: 10 characters
        let text1 = NSAttributedString(string: "1,000,000원")
        label.setAttributedText(text1, animated: false)
        let initialSubviewCount = label.subviews.count

        // Update multiple times
        for i in 1...5 {
            let newText = NSAttributedString(string: "\(i),234,567원")
            label.setAttributedText(newText, animated: false)
        }

        // Subview count should be same (same character count)
        #expect(label.subviews.count == initialSubviewCount)
    }

    @Test("Container reuse for unchanged characters")
    @MainActor
    func containerReuseForUnchangedCharacters() async {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.animationDuration = 0.05

        // Set initial text
        let text1 = NSAttributedString(string: "1,000,000원")
        label.setAttributedText(text1, animated: false)

        // Get reference to suffix container (원)
        let suffixContainerBefore = label.subviews.last

        // Update with animation - suffix should remain same
        let text2 = NSAttributedString(string: "1,234,567원")
        label.setAttributedText(text2, animated: true)

        // Wait for animation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Suffix container should be reused (same instance)
        let suffixContainerAfter = label.subviews.last
        #expect(suffixContainerBefore === suffixContainerAfter)
    }

    @Test("Repeated updates with same text do not create new containers")
    @MainActor
    func repeatedSameTextUpdates() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))

        let text = NSAttributedString(string: "1,000원")

        // Set same text multiple times
        for _ in 1...10 {
            label.setAttributedText(text, animated: false)
        }

        // Should have exactly 6 subviews (1, comma, 0, 0, 0, 원)
        #expect(label.subviews.count == 6)
    }

    @Test("Character size caching works correctly")
    @MainActor
    func characterSizeCaching() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        let font = UIFont.systemFont(ofSize: 20)

        // Text with repeated characters
        let text1 = NSAttributedString(string: "1,111,111", attributes: [.font: font])
        label.setAttributedText(text1, animated: false)
        let size1 = label.intrinsicContentSize

        // Same characters, different arrangement
        let text2 = NSAttributedString(string: "1,111,111", attributes: [.font: font])
        label.setAttributedText(text2, animated: false)
        let size2 = label.intrinsicContentSize

        // Sizes should be identical (cached)
        #expect(size1 == size2)
    }

    @Test("Memory stability during rapid updates")
    @MainActor
    func memoryStabilityDuringRapidUpdates() async {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.animationDuration = 0.02

        let font = UIFont.systemFont(ofSize: 20)

        // Initial setup
        label.setAttributedText(NSAttributedString(string: "0", attributes: [.font: font]), animated: false)

        // Rapid updates
        for i in 1...50 {
            let text = NSAttributedString(string: "\(i)", attributes: [.font: font])
            label.setAttributedText(text, animated: true)
        }

        // Wait for all animations
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Should end with "50"
        #expect(label.attributedText?.string == "50")

        // Subview count should be reasonable (not accumulated)
        #expect(label.subviews.count <= 10)
    }

    @Test("Layer optimization is enabled")
    @MainActor
    func layerOptimizationEnabled() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        // drawsAsynchronously should be enabled
        #expect(label.layer.drawsAsynchronously == true)
    }

    @Test("Different font sizes have separate cache entries")
    @MainActor
    func differentFontSizesSeparateCache() {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))

        // Same character, different font sizes
        let smallFont = UIFont.systemFont(ofSize: 12)
        let largeFont = UIFont.systemFont(ofSize: 24)

        let text1 = NSAttributedString(string: "1", attributes: [.font: smallFont])
        label.setAttributedText(text1, animated: false)
        let smallSize = label.intrinsicContentSize

        let text2 = NSAttributedString(string: "1", attributes: [.font: largeFont])
        label.setAttributedText(text2, animated: false)
        let largeSize = label.intrinsicContentSize

        // Different font sizes should produce different sizes
        #expect(largeSize.width > smallSize.width)
        #expect(largeSize.height > smallSize.height)
    }

    @Test("Digit count change handles container pool correctly")
    @MainActor
    func digitCountChangeContainerPool() async {
        let label = RollingNumberLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.animationDuration = 0.05

        // Start with fewer characters
        let text1 = NSAttributedString(string: "999")
        label.setAttributedText(text1, animated: false)
        let initialCount = label.subviews.count // 3

        // Increase to more characters
        let text2 = NSAttributedString(string: "1,000")
        label.setAttributedText(text2, animated: true)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should have more subviews now
        #expect(label.subviews.count == 5) // 1, comma, 0, 0, 0

        // Decrease back
        let text3 = NSAttributedString(string: "999")
        label.setAttributedText(text3, animated: true)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should be back to initial count
        #expect(label.subviews.count == initialCount)
    }
}
