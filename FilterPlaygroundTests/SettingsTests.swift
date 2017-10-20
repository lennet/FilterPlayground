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
    
}
