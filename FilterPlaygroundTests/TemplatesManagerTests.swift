//
//  TemplatesManagerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 08.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class TemplatesManagerTests: XCTestCase {
    func testNotEmpty() {
        XCTAssertGreaterThan(TemplatesManager.getURLs().count, 0)
    }
}
