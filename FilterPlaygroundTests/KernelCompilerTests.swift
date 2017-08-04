//
//  KernelCompilerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class KernelCompilerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidWarpKernel() {
        let source = "kernel vec2 foo() { return destCoord(); }"
        let result = KernelCompiler<CIWarpKernel>.compile(source: source)
        
        if case .failed(let errors) = result {
            XCTFail("\(errors.count) unexpected errors")
        }
        
    }
    
    func testInvalidWarpKernel() {
        let source = "kernel vec2 foo() { return destCoord() }"
        let result = KernelCompiler<CIWarpKernel>.compile(source: source)
        
        switch result {
        case .failed(let errors):
            XCTAssertGreaterThan(errors.count, 0)
            break
        default:
            XCTFail()
        }
    }
    
    func testValidColorKernel() {
        let source = "kernel vec4 foo() { return vec4(1.0,1.0,1.0,1.0); }"
        let result = KernelCompiler<CIColorKernel>.compile(source: source)
        
        if case .failed(let errors) = result {
            XCTFail("\(errors.count) unexpected errors")
        }
        
    }
    
    func testInvalidColorKernel() {
        let source = "kernel vec2 foo() { return destCoord() }"
        let result = KernelCompiler<CIColorKernel>.compile(source: source)
        
        switch result {
        case .failed(let errors):
            XCTAssertGreaterThan(errors.count, 0)
            break
        default:
            XCTFail()
        }
    }

    
}
