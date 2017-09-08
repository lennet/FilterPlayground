//
//  ErrorHelperTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ErrorHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testValidKernel() {
        let errorHelper = ErrorHelper()
        _ = CIKernel(source: "kernel vec2 foo() { return destCoord(); }")
        XCTAssertNil(errorHelper.errorString())
    }

    func testInvalidKernel() {
        let errorHelper = ErrorHelper()
        _ = CIKernel(source: "kernel vec2 foo() { return destCoord() }")
        let errorString = errorHelper.errorString()
        XCTAssertNotNil(errorString)

        let error = ErrorParser.compileErrors(for: errorString!)
        XCTAssertGreaterThan(error.count, 0)
    }
}
