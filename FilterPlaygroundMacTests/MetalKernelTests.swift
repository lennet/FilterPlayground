//
//  MetalKernelTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlaygroundMac

class MetalKernelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompileError() {
        let source = """
kernel vec2 untitled() {
    
}
"""
        let result = MetalKernel.compile(source: source)
        switch result {
        case let .failed(errors):
            let expectedFirstError = KernelError.compile(lineNumber: 1, characterIndex: 8, type: "error", message: "unknown type name \'vec2\'\nkernel vec2 untitled() {\n       ^\n", note: nil)
            let expectedSecondError = KernelError.compile(lineNumber: 1, characterIndex: 13, type: "error", message: "kernel must have void return type\nkernel vec2 untitled() {\n            ^\n", note: nil)
            
            XCTAssertEqual(errors.first!, expectedFirstError)
            XCTAssertEqual(errors.last!, expectedSecondError)
            XCTAssertEqual(errors.count, 2)
            break
        default:
            XCTFail()
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
