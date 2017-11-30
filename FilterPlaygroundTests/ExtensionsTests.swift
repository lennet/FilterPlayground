//
//  ExtensionsTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import simd
import XCTest

class ExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFloat2Codable() {
        let value = float2(1, 2)
        let data = try! JSONEncoder().encode(value)
        let decodedValue = try! JSONDecoder().decode(float2.self, from: data)
        XCTAssertEqual(value, decodedValue)
    }
}
