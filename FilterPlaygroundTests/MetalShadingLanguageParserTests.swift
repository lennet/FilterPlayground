//
//  MetalShadingLanguageParserTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class MetalShadingLanguageParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let source = MetalKernel.initialSource(with: "untitled")
        let parser = MetalShadingLanguageParser(string: source)
        let kernelDefinition = parser.getKernelDefinition()
        let expectedArguments = [KernelDefinitionArgument(name: "inTexture", type: .texture2d, access: .read), KernelDefinitionArgument(name: "outTexture", type: .texture2d, access: .write), KernelDefinitionArgument(name: "gid", type: .uint2)]
        let expectedResult = KernelDefinition(name: "untitled", returnType: .void, arguments: expectedArguments)
        XCTAssertEqual(expectedResult, kernelDefinition)
    }

    func testGetArgument() {
        let source = "uint2 gid [[thread_position_in_grid]]"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens)
        let expectedResult = KernelDefinitionArgument(name: "gid", type: .uint2)
        XCTAssertEqual(argument, expectedResult)
    }

    func testGetArgumentRead() {
        let source = "texture2d<float, access::read> inTexture [[texture(0)]],"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens)
        let expectedResult = KernelDefinitionArgument(name: "inTexture", type: .texture2d, access: .read)
        XCTAssertEqual(argument, expectedResult)
    }

    func testGetArgumentWrite() {
        let source = "texture2d<float, access::write> outTexture [[texture(1)]],"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens)
        let expectedResult = KernelDefinitionArgument(name: "outTexture", type: .texture2d, access: .write)
        XCTAssertEqual(argument, expectedResult)
    }
}
