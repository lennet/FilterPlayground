//
//  FrameRateManagerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 20.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class MockFrameRateManager: FrameRateManager {

    var mockIsLowPowerModeEnabled = false
    override var isLowPowerModeEnabled: Bool {
        return mockIsLowPowerModeEnabled
    }
}

class FrameRateManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Settings.ignoreLowPowerMode = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLowPowerMode() {
        let frameRateManager = MockFrameRateManager()
        XCTAssertFalse(frameRateManager.frameRate == frameRateManager.lowPowerModeFrameRate)
        XCTAssertTrue(frameRateManager.frameRate == frameRateManager.maxFrameRate)
        frameRateManager.mockIsLowPowerModeEnabled = true
        XCTAssertTrue(frameRateManager.frameRate == frameRateManager.lowPowerModeFrameRate)
        XCTAssertFalse(frameRateManager.frameRate == frameRateManager.maxFrameRate)
    }

    func testLowPowerModeEnabledWithLowerCustomFrameRate() {
        let frameRateManager = MockFrameRateManager()
        frameRateManager.mockIsLowPowerModeEnabled = true
        let custom = 10
        XCTAssertFalse(frameRateManager.frameRate == custom)
        frameRateManager.customFrameRate = custom
        XCTAssertFalse(frameRateManager.frameRate == frameRateManager.lowPowerModeFrameRate)
        XCTAssertTrue(frameRateManager.frameRate == custom)
    }

    func testLowPowerModeEnabledWithHigherCustomFrameRate() {
        let frameRateManager = MockFrameRateManager()
        frameRateManager.mockIsLowPowerModeEnabled = true
        let custom = frameRateManager.lowPowerModeFrameRate + 10
        XCTAssertFalse(frameRateManager.frameRate == custom)
        frameRateManager.customFrameRate = custom
        XCTAssertTrue(frameRateManager.frameRate == frameRateManager.lowPowerModeFrameRate)
        XCTAssertFalse(frameRateManager.frameRate == custom)
    }

    func testNotHigherThanMaxFrameRate() {
        let frameRateManager = MockFrameRateManager()
        frameRateManager.mockIsLowPowerModeEnabled = false
        let custom = frameRateManager.maxFrameRate * 2
        XCTAssertFalse(frameRateManager.frameRate == custom)
        frameRateManager.customFrameRate = custom
        XCTAssertTrue(frameRateManager.frameRate == frameRateManager.maxFrameRate)
        XCTAssertFalse(frameRateManager.frameRate == custom)
    }

    func testNotificationAfterCustomFrameRateChange() {
        expectation(forNotification: FrameRateManager.frameRateChangedNotificationName, object: nil, handler: nil)
        let frameRateManager = MockFrameRateManager()
        frameRateManager.customFrameRate = 40
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNotificationAfterLowPowerModeChanged() {
        expectation(forNotification: FrameRateManager.frameRateChangedNotificationName, object: nil, handler: nil)
        _ = FrameRateManager.shared
        NotificationCenter.default.post(name: .NSProcessInfoPowerStateDidChange, object: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFrameRateInLowPowerModeWithIgnoresLowPowerModeEnabled() {
        let frameRateManager = MockFrameRateManager()
        frameRateManager.mockIsLowPowerModeEnabled = true
        Settings.ignoreLowPowerMode = true
        XCTAssertFalse(frameRateManager.frameRate == frameRateManager.lowPowerModeFrameRate)
        XCTAssertTrue(frameRateManager.frameRate == frameRateManager.maxFrameRate)
    }

    func testNotificationAfterIgnoreLowPowerModeSettingChanged() {
        expectation(forNotification: FrameRateManager.frameRateChangedNotificationName, object: nil, handler: nil)
        let frameRateManager = MockFrameRateManager()
        frameRateManager.mockIsLowPowerModeEnabled = true

        Settings.ignoreLowPowerMode = true
        waitForExpectations(timeout: 1, handler: nil)
    }
}
