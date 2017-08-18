//
//  ErrorParserTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ErrorParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseSingleError() {
        let error =
"""
[CIKernelPool] 1:1: ERROR: unknown type name 'asdads'
asdads
^
1 error generated.
2017-07-31 18:22:20.371780+0200 FilterPlayground[39291:2779720] [compile] [CIWarpKernel initWithString:] failed due to error parsing kernel source.
"""
        
        let errors = ErrorParser.getErrors(for: error)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, CompilerError(lineNumber: 1, characterIndex: 1, type: "ERROR", message: "unknown type name 'asdads'", note: nil))
    }
    
    func testErrorWithNote() {
        let errorString = """
[CIKernelPool] 3:2: ERROR: expected '}'
}
 ^
[CIKernelPool] 1:36: note:" to match this '{'
kernel vec4 untitled(__sample img) {
                                   ^
"""
        
        let errors = ErrorParser.getErrors(for: errorString)
        XCTAssertEqual(errors.count, 1)
        let note = (1, 36, " to match this '{'")
        let error = CompilerError(lineNumber: 3, characterIndex: 2, type: "ERROR", message: "expected '}'", note: note)
        XCTAssertEqual(errors.first!, error)
    }
    
    
    func testErrorWithNote2() {
        let errorString = """
        [CIKernelPool] 4:2: ERROR: function declared with return type 'vec4', but returning type 'vec2'
        return  destCoord()
            ^
            [CIKernelPool] 1:8: note: return type declared here
        kernel vec4 untitled(__sample img) {
            ^
        """
        
        let errors = ErrorParser.getErrors(for: errorString)
        XCTAssertEqual(errors.count, 1)
        let note = (1, 8, " return type declared here")
        let error = CompilerError(lineNumber: 4, characterIndex: 2, type: "ERROR", message: "function declared with return type 'vec4', but returning type 'vec2'", note: note)
        XCTAssertEqual(errors.first!, error)
    }
}
