//
//  KernelCompilerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlaygroundMac
import XCTest

class KernelCompilerTests: XCTestCase {
    func testValidWarpKernel() {
        let source = "kernel vec2 foo() { return destCoord(); }"
        let exp = expectation(description: "wait for compilation")
        CoreImageWarpKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInvalidWarpKernel() {
        let source = "kernel vec2 foo() { return destCoord() }"
        let exp = expectation(description: "wait for compilation")
        CoreImageWarpKernel().compile(source: source) { result in
            switch result {
            case let .failed(errors):
                XCTAssertGreaterThan(errors.count, 0)
                break
            default:
                XCTFail()
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testValidColorKernel() {
        let source = "kernel vec4 foo() { return vec4(1.0,1.0,1.0,1.0); }"

        let exp = expectation(description: "wait for compilation")
        CoreImageColorKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInvalidColorKernel() {
        let source = "kernel vec2 foo() { return destCoord() }"
        let exp = expectation(description: "wait for compilation")
        CoreImageColorKernel().compile(source: source) { result in
            switch result {
            case let .failed(errors):
                XCTAssertGreaterThan(errors.count, 0)
                break
            default:
                XCTFail()
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInitialSourceDefault() {
        let source = KernelType.coreimage.kernelClass.initialSource(with: "untitled")
        let exp = expectation(description: "wait for compilation")
        CoreImageKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInitialSourceWarp() {
        let source = KernelType.coreimagewarp.kernelClass.initialSource(with: "untitled")
        let exp = expectation(description: "wait for compilation")
        CoreImageWarpKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInitialSourceColor() {
        let source = KernelType.coreimagecolor.kernelClass.initialSource(with: "untitled")
        let exp = expectation(description: "wait for compilation")
        CoreImageColorKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

    func testInitialSourceBlend() {
        let source = KernelType.coreimageblend.kernelClass.initialSource(with: "untitled")
        let exp = expectation(description: "wait for compilation")
        CoreImageBlendKernel().compile(source: source) { result in
            if case let .failed(errors) = result {
                XCTFail("\(errors.count) unexpected errors")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }
}
