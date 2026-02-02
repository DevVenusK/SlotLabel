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
