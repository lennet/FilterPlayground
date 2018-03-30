//
//  MetalKernelTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlaygroundMac
import XCTest

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
        let exp = XCTestExpectation(description: "waiting for compilation")
        MetalKernel().compile(source: source) { result in
            switch result {
            case let .failed(errors):
                let expectedFirstError = KernelError.compile(lineNumber: 1, characterIndex: 8, type: .error, message: "unknown type name \'vec2\'", note: nil)
                let expectedSecondError = KernelError.compile(lineNumber: 1, characterIndex: 13, type: .error, message: "kernel must have void return type", note: nil)

                XCTAssertEqual(errors.first!, expectedFirstError)
                XCTAssertEqual(errors.last!, expectedSecondError)
                XCTAssertEqual(errors.count, 2)
                break
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCompilerMetalKernelWarnings() {
        let source = """
                #include <metal_stdlib>
                using namespace metal;
                
                kernel void untitled(
                texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                uint2 gid [[thread_position_in_grid]])
                
                {
                    float a;
                
                }
        """

        let exp = XCTestExpectation(description: "waiting for compilation")
        let kernel = MetalKernel()
        kernel.compile(source: source) { result in
            switch result {
            case let .success(errors: errors):
                let expectedFirstError = KernelError.compile(lineNumber: 10, characterIndex: 19, type: .warning, message: "unused variable 'a'", note: nil)

                XCTAssertEqual(errors.first!, expectedFirstError)
                XCTAssertEqual(errors.count, 1)
                XCTAssertNotNil(kernel.library)
                break
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testCompileMetalKernel() {
        let source = MetalKernel.initialSource(with: "untitled")
        let exp = XCTestExpectation(description: "waiting for compilation")
        MetalKernel().compile(source: source) { result in
            switch result {
            case .success(errors: _):
                break
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
}
