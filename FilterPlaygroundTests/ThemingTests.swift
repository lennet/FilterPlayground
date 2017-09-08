//
//  ThemingTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 05.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ThemingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThemeChangedNotification() {
        let expectation = XCTestExpectation(description: "waiting for notification")

        let theme = NightTheme.self
        NotificationCenter.default.addObserver(forName: ThemeManager.themeChangedNotificationName, object: nil, queue: nil) { notification in
            XCTAssertNotNil(notification.object.self is Theme.Type)
            expectation.fulfill()
        }

        ThemeManager.shared.currentTheme = theme
        wait(for: [expectation], timeout: 5)
    }
}
