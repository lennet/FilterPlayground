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
    func testFloat2Codable() {
        let value = float2(1, 2)
        let data = try! JSONEncoder().encode(value)
        let decodedValue = try! JSONDecoder().decode(float2.self, from: data)
        XCTAssertEqual(value, decodedValue)
    }
}
