//
//  ASTTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ASTTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMethod() {
        let text = "foo{ bar(); }"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        XCTAssertEqual(result.1.count, 0)
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                body: [.statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon])],
                                                  postfix: [.whiteSpace, .closingBracket])
        XCTAssertEqual(result.0, [expectedResult])
    }
    
    func testComment() {
        let text = "//hello world"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        XCTAssertEqual(result.1.count, 0)
        
        let expectedResult = ASTNode.comment("//hello world")
        XCTAssertEqual(result.0, [expectedResult])
    }
    
    func testCommentAndMethod() {
        let text = "//hello world\nfoo{ bar(); }"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        XCTAssertEqual(result.1.count, 0)
        
        let expectedResult = [ASTNode.comment("//hello world"),
                              ASTNode.bracetStatement(prefix: [.newLine, .identifier(.other("foo")), .openingBracket],
                                                     body: [.statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon])],
                                                     postfix: [.whiteSpace, .closingBracket])]
        XCTAssertEqual(result.0, expectedResult)
    }
    
    func testCommentInMethod() {
        let text = "foo{ //hello world\n bar(); }"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        XCTAssertEqual(result.1.count, 0)
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [.statement([.whiteSpace]),
                                                            .comment("//hello world"),
                                                            .statement([.newLine, .whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon])],
                                                     postfix: [.whiteSpace, .closingBracket])
        XCTAssertEqual(result.0, [expectedResult])
    }
    
}
