//
//  ThemingTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 05.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class ThemingTests: XCTestCase {
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
