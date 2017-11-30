//
//  ErrorParserTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

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

        let errors = CoreImageErrorParser.compileErrors(for: error)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, KernelError.compile(lineNumber: 1, characterIndex: 1, type: .error, message: "unknown type name 'asdads'", note: nil))
    }

    func testErrorWithNote() {
        let errorString = """
        [CIKernelPool] 3:2: ERROR: expected '}'
        }
         ^
        [CIKernelPool] 1:36: note: to match this '{'
        kernel vec4 untitled(__sample img) {
                                           ^
        """

        let errors = CoreImageErrorParser.compileErrors(for: errorString)
        XCTAssertEqual(errors.count, 1)
        let note = (1, 36, "to match this '{'")
        let error = KernelError.compile(lineNumber: 3, characterIndex: 2, type: .error, message: "expected '}'", note: note)
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

        let errors = CoreImageErrorParser.compileErrors(for: errorString)
        XCTAssertEqual(errors.count, 1)
        let note = (1, 8, "return type declared here")
        let error = KernelError.compile(lineNumber: 4, characterIndex: 2, type: .error, message: "function declared with return type 'vec4', but returning type 'vec2'", note: note)
        XCTAssertEqual(errors.first!, error)
    }

    // input to get this error: vec2 test() { return destCoord(); }
    func testUnkownError() {
        let error = """
        2017-09-11 17:21:57.296768+0200 FilterPlayground[6926:528702] [compile] [CIWarpKernel initWithString:] failed due to error parsing kernel source.
        """

        let errors = CoreImageErrorParser.compileErrors(for: error)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first!, KernelError.compile(lineNumber: -1, characterIndex: -1, type: .error, message: "failed due to error parsing kernel source.", note: nil))
    }

    func testRuntimeErrors() {
        let errorString = """
        2017-08-23 22:51:41.564656+0200 FilterPlayground[1140:1368834] [api] -[CIColorKernel applyWithExtent:arguments:options:] argument count mismatch for kernel \'untitled\', expected 1 but saw 0.\n
        """
        let errors = CoreImageErrorParser.runtimeErrors(for: errorString)
        XCTAssertEqual(errors.count, 1)
        let error = KernelError.runtime(message: "argument count mismatch for kernel 'untitled', expected 1 but saw 0.")
        XCTAssertEqual(errors.first!, error)
    }

    func testRuntimeErrorParserWithEmptyInput() {
        let errorString = ""
        let errors = CoreImageErrorParser.runtimeErrors(for: errorString)
        XCTAssertEqual(errors.count, 0)
    }

    func testMetalErrorParser() {
        let errorString = "Compilation failed: \n\nprogram_source:1:8: error: unknown type name \'vec2\'\nkernel vec2 untitled() {\n       ^\nprogram_source:1:13: error: kernel must have void return type\nkernel vec2 untitled() {\n            ^\n"
        let errors = MetalErrorParser.compileErrors(for: errorString)

        let expectedFirstError = KernelError.compile(lineNumber: 1, characterIndex: 8, type: .error, message: "unknown type name \'vec2\'", note: nil)
        let expectedSecondError = KernelError.compile(lineNumber: 1, characterIndex: 13, type: .error, message: "kernel must have void return type", note: nil)

        XCTAssertEqual(errors.first!, expectedFirstError)
        XCTAssertEqual(errors.last!, expectedSecondError)
        XCTAssertEqual(errors.count, 2)
    }

    func testMetalErrorParserWarning() {
        let errorString = """
        Compilation succeeded with:
        
        program_source:10:19: warning: unused variable 'a'
        float a;
        ^
        """
        let errors = MetalErrorParser.compileErrors(for: errorString)

        let expectedFirstError = KernelError.compile(lineNumber: 10, characterIndex: 19, type: .warning, message: "unused variable 'a'", note: nil)

        XCTAssertEqual(errors.first!, expectedFirstError)
        XCTAssertEqual(errors.count, 1)
    }
}
