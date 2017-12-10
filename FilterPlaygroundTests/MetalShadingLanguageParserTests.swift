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
        let expectedArguments = [KernelDefinitionArgument(index: 0, name: "inTexture", type: .texture2d, access: .read, origin: .texture), KernelDefinitionArgument(index: 1, name: "outTexture", type: .texture2d, access: .write, origin: .texture), KernelDefinitionArgument(index: 2, name: "gid", type: .uint2, origin: .other("thread_position_in_grid"))]
        let expectedResult = KernelDefinition(name: "untitled", returnType: .void, arguments: expectedArguments)
        XCTAssertEqual(expectedResult, kernelDefinition)
    }

    func testGetArgument() {
        let source = "uint2 gid [[thread_position_in_grid]]"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.tokenizer.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens, index: 0)
        let expectedResult = KernelDefinitionArgument(index: 0, name: "gid", type: .uint2, origin: .other("thread_position_in_grid"))
        XCTAssertEqual(argument, expectedResult)
    }

    func testGetArgumentRead() {
        let source = "texture2d<float, access::read> inTexture [[texture(0)]],"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.tokenizer.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens, index: 0)
        let expectedResult = KernelDefinitionArgument(index: 0, name: "inTexture", type: .texture2d, access: .read, origin: .texture)
        XCTAssertEqual(argument, expectedResult)
    }

    func testGetArgumentWrite() {
        let source = "texture2d<float, access::write> outTexture [[texture(1)]],"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.tokenizer.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens, index: 0)
        let expectedResult = KernelDefinitionArgument(index: 0, name: "outTexture", type: .texture2d, access: .write, origin: .texture)
        XCTAssertEqual(argument, expectedResult)
    }

    func testGetArgumentConstant() {
        let source = "constant float saturation [[buffer(0)]]"
        let parser = MetalShadingLanguageParser(string: source)
        let tokens = parser.tokenizer.getTokens().filter { (token) -> Bool in
            return !token.isSpaceTabOrNewLine
        }
        let argument = parser.argument(for: tokens, index: 0)
        let expectedResult = KernelDefinitionArgument(index: 0, name: "saturation", type: .float, access: .constant, origin: .buffer)
        XCTAssertEqual(argument, expectedResult)
    }

    func testInserArgument() {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled ()
        
        {
        
        
        }
        """

        let expectedSource = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled (float test [[test]])
        
        {
        
        
        }
        """
        let argument = KernelDefinitionArgument(index: 0, name: "test", type: .float, origin: .other("test"))
        let result = MetalShadingLanguageParser(string: source).textWithInserted(arguments: [argument])
        XCTAssertEqual(expectedSource, result)
    }

    func testInserBufferArgument() {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled ()
        
        {
        
        
        }
        """

        let expectedSource = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled (float test [[buffer(0)]])
        
        {
        
        
        }
        """
        let argument = KernelDefinitionArgument(index: 0, name: "test", type: .float, origin: .buffer)
        let result = MetalShadingLanguageParser(string: source).textWithInserted(arguments: [argument])
        XCTAssertEqual(expectedSource, result)
    }

    func testInserArgumentWithExistingArgument() {
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled (uint a [[test]])
        
        {
        
        
        }
        """

        let expectedSource = """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled (float test [[test]])
        
        {
        
        
        }
        """
        let argument = KernelDefinitionArgument(index: 0, name: "test", type: .float, origin: .other("test"))
        let result = MetalShadingLanguageParser(string: source).textWithInserted(arguments: [argument])
        XCTAssertEqual(expectedSource, result)
    }
}
