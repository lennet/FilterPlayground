//
//  ASTCodeCompletionTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 25.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ASTCodeCompletionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSemicolonAfterStatement() {
        let code = "float a = 5.0"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 7)
        XCTAssertEqual(result.first ?? "", ";")
    }
    
    func testSemicolonAfterStatementInFunction() {
        let code = "kernel a () { float b = 5.0 }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 16)
        XCTAssertTrue(result.contains(";"))
    }
    
    func testArgumentsInFuctions() {
        let code = "kernel vec2 a (float c, float d) {  }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 17)
        XCTAssertTrue(result.contains("c"))
        XCTAssertTrue(result.contains("d"))
    }
    
    func testReturnInFunction() {
        let code = "kernel vec2 a (float c, float d) {  }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 17)
        XCTAssertTrue(result.contains("return "))
    }
    
    func testReturnInFunctionAlreadyExists() {
        let code = "kernel vec2 a (float c, float d) {  return }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 17)
        XCTAssertFalse(result.contains("return "))
    }
    
    func testFunctionAboveKernelFunction() {
        let code = "vec2 foo (float c, float d) {  } kernel vec2 a (float c, float d) {return  }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 40)
        XCTAssertTrue(result.contains("foo"))
    }
    
    func testFunctionWithoutBody() {
        let code = "vec2 foo () {} kernel vec2 a(){}"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 13)
        XCTAssertFalse(result.contains("foo"))
    }
    
    func testFunctionInBody() {
        let code = "vec2 foo () {} kernel vec2 a(){return  }"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 20)
        XCTAssertTrue(result.contains("foo"))
    }
    
    func testEmptySource() {
        let code = " "
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 0, with: KernelAttributeType.all.map{ $0.rawValue })
        XCTAssertTrue(result.contains("vec2"))
        XCTAssertTrue(result.contains("vec3"))
        XCTAssertTrue(result.contains("vec4"))
        XCTAssertTrue(result.contains("float"))
    }
    
    func testFirstLineOfBody() {
        let code = "vec2 foo () {} kernel vec2 a(){ return vec2(0.0, 0.0);}"
        let ast = Parser(string: code).getAST()
        let result = ast.codeCompletion(at: 18)
        XCTAssertFalse(result.isEmpty)
    }
    
}
