//
//  ErrorHelperTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlaygroundMac
import XCTest

class ErrorHelperTests: XCTestCase {
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

        let error = CoreImageErrorParser.compileErrors(for: errorString!)
        XCTAssertGreaterThan(error.count, 0)
    }
}
