//
//  RollingNumberLabelDemoUITests.swift
//  RollingNumberLabelDemoUITests
//
//  Created on 2026-02-02.
//

import XCTest

final class RollingNumberLabelDemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Tests

    func testNavigationToBasicDemo() throws {
        app.cells["Basic Demo"].tap()
        XCTAssertTrue(app.navigationBars["Basic Demo"].exists)
    }

    func testNavigationToCurrencyDemo() throws {
        app.cells["Currency Demo"].tap()
        XCTAssertTrue(app.navigationBars["Currency Demo"].exists)
    }

    func testNavigationToCustomizationDemo() throws {
        app.cells["Customization Demo"].tap()
        XCTAssertTrue(app.navigationBars["Customization"].exists)
    }

    func testNavigationToStressTest() throws {
        app.cells["Stress Test"].tap()
        XCTAssertTrue(app.navigationBars["Stress Test"].exists)
    }

    // MARK: - Basic Demo Tests

    func testBasicDemoIncreaseButtons() throws {
        app.cells["Basic Demo"].tap()

        // Test increase buttons
        let increaseBy10 = app.buttons["increaseBy10"]
        XCTAssertTrue(increaseBy10.exists)
        increaseBy10.tap()

        let increaseBy100 = app.buttons["increaseBy100"]
        XCTAssertTrue(increaseBy100.exists)
        increaseBy100.tap()

        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)
    }

    func testBasicDemoDecreaseButtons() throws {
        app.cells["Basic Demo"].tap()

        let decreaseBy10 = app.buttons["decreaseBy10"]
        XCTAssertTrue(decreaseBy10.exists)
        decreaseBy10.tap()

        let decreaseBy100 = app.buttons["decreaseBy100"]
        XCTAssertTrue(decreaseBy100.exists)
        decreaseBy100.tap()

        Thread.sleep(forTimeInterval: 0.5)
    }

    func testBasicDemoRandomButton() throws {
        app.cells["Basic Demo"].tap()

        let randomButton = app.buttons["randomButton"]
        XCTAssertTrue(randomButton.exists)

        // Tap multiple times to test animation queueing
        randomButton.tap()
        randomButton.tap()
        randomButton.tap()

        Thread.sleep(forTimeInterval: 1.0)
    }

    func testBasicDemoResetButton() throws {
        app.cells["Basic Demo"].tap()

        let randomButton = app.buttons["randomButton"]
        randomButton.tap()

        Thread.sleep(forTimeInterval: 0.5)

        let resetButton = app.buttons["resetButton"]
        XCTAssertTrue(resetButton.exists)
        resetButton.tap()

        Thread.sleep(forTimeInterval: 0.5)
    }

    // MARK: - Currency Demo Tests

    func testCurrencyDemoAmountButtons() throws {
        app.cells["Currency Demo"].tap()

        // Test amount adjustment buttons
        let plus100000 = app.buttons["amount_100000"]
        XCTAssertTrue(plus100000.exists)
        plus100000.tap()

        Thread.sleep(forTimeInterval: 0.5)

        let minus100000 = app.buttons["amount_-100000"]
        XCTAssertTrue(minus100000.exists)
        minus100000.tap()

        Thread.sleep(forTimeInterval: 0.5)
    }

    func testCurrencyDemoDigitCountChange() throws {
        app.cells["Currency Demo"].tap()

        // Test digit count increase: 999,999 -> 1,000,000
        let set999999 = app.buttons["set999999"]
        XCTAssertTrue(set999999.exists)
        set999999.tap()

        Thread.sleep(forTimeInterval: 0.5)

        let set1000000 = app.buttons["set1000000"]
        XCTAssertTrue(set1000000.exists)
        set1000000.tap()

        Thread.sleep(forTimeInterval: 0.5)

        // Test digit count decrease: 1,000,000 -> 999,999
        set999999.tap()

        Thread.sleep(forTimeInterval: 0.5)
    }

    func testCurrencyDemoLargeNumber() throws {
        app.cells["Currency Demo"].tap()

        let set10000000 = app.buttons["set10000000"]
        XCTAssertTrue(set10000000.exists)
        set10000000.tap()

        Thread.sleep(forTimeInterval: 0.5)
    }

    // MARK: - Customization Demo Tests

    func testCustomizationDemoAlignmentPicker() throws {
        app.cells["Customization Demo"].tap()

        let alignmentPicker = app.segmentedControls["alignmentPicker"]
        XCTAssertTrue(alignmentPicker.exists)

        // Test different alignments
        alignmentPicker.buttons["Left"].tap()
        Thread.sleep(forTimeInterval: 0.3)

        alignmentPicker.buttons["Center"].tap()
        Thread.sleep(forTimeInterval: 0.3)

        alignmentPicker.buttons["Right"].tap()
        Thread.sleep(forTimeInterval: 0.3)
    }

    func testCustomizationDemoDurationSlider() throws {
        app.cells["Customization Demo"].tap()

        let slider = app.sliders["durationSlider"]
        XCTAssertTrue(slider.exists)

        // Adjust slider
        slider.adjust(toNormalizedSliderPosition: 0.8)
        Thread.sleep(forTimeInterval: 0.3)
    }

    func testCustomizationDemoFontSizeSlider() throws {
        app.cells["Customization Demo"].tap()

        let slider = app.sliders["fontSizeSlider"]
        XCTAssertTrue(slider.exists)

        slider.adjust(toNormalizedSliderPosition: 0.5)
        Thread.sleep(forTimeInterval: 0.3)
    }

    // MARK: - Stress Test Demo Tests

    func testStressTestToggle() throws {
        app.cells["Stress Test"].tap()

        let toggleButton = app.buttons["toggleButton"]
        XCTAssertTrue(toggleButton.exists)

        // Start
        toggleButton.tap()
        Thread.sleep(forTimeInterval: 1.0)

        // Stop
        toggleButton.tap()
        Thread.sleep(forTimeInterval: 0.3)
    }

    func testStressTestReset() throws {
        app.cells["Stress Test"].tap()

        let toggleButton = app.buttons["toggleButton"]
        toggleButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        toggleButton.tap() // Stop

        let resetButton = app.buttons["resetButton"]
        XCTAssertTrue(resetButton.exists)
        resetButton.tap()

        Thread.sleep(forTimeInterval: 0.3)
    }

    func testStressTestIntervalSlider() throws {
        app.cells["Stress Test"].tap()

        let slider = app.sliders["intervalSlider"]
        XCTAssertTrue(slider.exists)

        slider.adjust(toNormalizedSliderPosition: 0.2)
        Thread.sleep(forTimeInterval: 0.3)
    }

    // MARK: - Performance Tests

    func testRapidUpdatesPerformance() throws {
        app.cells["Basic Demo"].tap()

        let randomButton = app.buttons["randomButton"]

        measure {
            for _ in 0..<10 {
                randomButton.tap()
            }
            Thread.sleep(forTimeInterval: 1.0)
        }
    }
}
