//
//  TemplatesManagerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 08.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class TemplatesManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotEmpty() {
        XCTAssertGreaterThan(TemplatesManager.getURLs().count, 0)
    }

}
