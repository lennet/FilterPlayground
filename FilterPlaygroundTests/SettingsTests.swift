//
//  SettingsTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 19.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class SettingsTests: XCTestCase {

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    func testTabsEnabled() {
        XCTAssertFalse(Settings.tabsEnabled)
        Settings.tabsEnabled = true
        XCTAssertTrue(Settings.tabsEnabled)
    }

    func testFontSize() {
        XCTAssertNotEqual(Settings.fontSize, 0)
        Settings.fontSize = 0
        XCTAssertEqual(Settings.fontSize, 0)
    }

    func testCustomFrameRate() {
        XCTAssertNil(Settings.customFrameRate)
        Settings.customFrameRate = 60
        XCTAssertEqual(Settings.customFrameRate!, 60)
    }

    func testIgnoreLowPowerMode() {
        XCTAssertFalse(Settings.ignoreLowPowerMode)
        Settings.ignoreLowPowerMode = true
        XCTAssertTrue(Settings.ignoreLowPowerMode)
    }

    func testNotificationAfterIgnoreLowPowerModeChanged() {
        expectation(forNotification: Settings.ignoreLowPowerModeChangedNotificationName, object: nil, handler: nil)
        Settings.ignoreLowPowerMode = true
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNotificationAfterCustomFrameRateChanged() {
        expectation(forNotification: Settings.customFrameRateChangedNotificationName, object: nil, handler: nil)
        Settings.customFrameRate = 10
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShowStatistics() {
        XCTAssertFalse(Settings.showStatistics)
        Settings.showStatistics = true
        XCTAssertTrue(Settings.showStatistics)
    }

    func testNotificationAfterShowStatisticsChanged() {
        expectation(forNotification: Settings.showStatisticsChangedNotificationName, object: nil, handler: nil)
        Settings.showStatistics = true
        waitForExpectations(timeout: 1, handler: nil)
    }
}
