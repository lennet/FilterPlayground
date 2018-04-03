//
//  KernelExecutionPipelineTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.03.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class KernelExecutionPipelineTests: XCTestCase {
    func testPreconditionErrors() {
        let kernel = MockKernel()
        kernel.mockRequiredInputImages = 100

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertFalse(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testPreconditionErrorsWithCompileWarning() {
        let kernel = MockKernel()
        kernel.mockCompilerResult = .success(warnings: [KernelError.compile(lineNumber: 0, characterIndex: 0, type: .warning, message: "", note: nil)])
        kernel.mockRequiredInputImages = 100

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 2)
            XCTAssertFalse(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testPreconditionErrorsWithCompileErrors() {
        let kernel = MockKernel()
        kernel.mockCompilerResult = .success(warnings: [KernelError.compile(lineNumber: 0, characterIndex: 0, type: .error, message: "", note: nil)])
        kernel.mockRequiredInputImages = 100

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 2)
            XCTAssertFalse(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testNoPreconditionErrorsWithCompileWarning() {
        let kernel = MockKernel()
        kernel.mockCompilerResult = .success(warnings: [KernelError.compile(lineNumber: 0, characterIndex: 0, type: .warning, message: "", note: nil)])

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertTrue(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testNoPreconditionErrorsWithCompileErrors() {
        let kernel = MockKernel()
        kernel.mockCompilerResult = .success(warnings: [KernelError.compile(lineNumber: 0, characterIndex: 0, type: .error, message: "", note: nil)])

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertFalse(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testPreconditionErrorsWithoutIssues() {
        let kernel = MockKernel()
        kernel.mockRequiredInputImages = 0

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 0)
            XCTAssertTrue(kernel.renderCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testExecutionWithoutCache() {
        let kernel = MockKernel()
        kernel.mockRequiredInputImages = 0

        let expectation = XCTestExpectation()
        _ = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 0)
            XCTAssertTrue(kernel.renderCalled)
            XCTAssertTrue(kernel.compileCalled)
            expectation.fulfill()
        }.execute(source: "test")
        wait(for: [expectation], timeout: 1)
    }

    func testExecutionWithoutCaching2() {
        let kernel = MockKernel()
        kernel.mockRequiredInputImages = 0

        let expectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()
        var firstOutput = true
        let executionPipeline: KernelExecutionPipeline

        executionPipeline = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 0)
            XCTAssertTrue(kernel.renderCalled)
            if firstOutput {
                XCTAssertTrue(kernel.compileCalled)
                firstOutput = false
                kernel.renderCalled = false
                kernel.compileCalled = false
                expectation.fulfill()
            } else {
                XCTAssertTrue(kernel.compileCalled)
                secondExpectation.fulfill()
            }
        }
        executionPipeline.execute(source: "test")
        wait(for: [expectation], timeout: 1)
        executionPipeline.execute(source: "test 2")
        wait(for: [secondExpectation], timeout: 1)
    }

    func testExecutionWithCaching() {
        let kernel = MockKernel()
        kernel.mockRequiredInputImages = 0

        let expectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()
        var firstOutput = true
        let executionPipeline = KernelExecutionPipeline(kernel: kernel) { errors in
            XCTAssertEqual(errors.count, 0)
            XCTAssertTrue(kernel.renderCalled)
            if firstOutput {
                XCTAssertTrue(kernel.compileCalled)
                firstOutput = false
                kernel.renderCalled = false
                kernel.compileCalled = false
                expectation.fulfill()
            } else {
                XCTAssertFalse(kernel.compileCalled)
                secondExpectation.fulfill()
            }
        }
        executionPipeline.execute(source: "test")
        wait(for: [expectation], timeout: 1)
        executionPipeline.execute(source: "test")
        wait(for: [secondExpectation], timeout: 2)
    }
}
