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
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                body: [.statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                    .unkown([.whiteSpace])],
                                                  postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }
    
    func testComment() {
        let text = "//hello world"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = ASTNode.comment(Parser(string:text).getTokens())
        XCTAssertEqual(result, [expectedResult])
    }
    
    func testCommentAndMethod() {
        let text = "//hello world\nfoo{ bar(); }"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = [ASTNode.comment(Parser(string:"//hello world").getTokens()),
                              ASTNode.bracetStatement(prefix: [.newLine, .identifier(.other("foo")), .openingBracket],
                                                     body: [.statement([.whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                                            .unkown([.whiteSpace])],
                                                     postfix: [.closingBracket])]
        XCTAssertEqual(result, expectedResult)
    }
    
    func testCommentInMethod() {
        let text = "foo{ //hello world\n bar(); }"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [.unkown([.whiteSpace]),
                                                            .comment(Parser(string:"//hello world").getTokens()),
                                                            .statement([.newLine, .whiteSpace, .identifier(.other("bar")), .identifier(.other("(")), .identifier(.other(")")), .semicolon]),
                                                            .unkown([.whiteSpace])],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }
    
    func testMethodWithNewLine() {
        let text = "foo{\n}"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [.unkown([.newLine])],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }
    
    func testEmptyMethod() {
        let text = "foo{}"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = ASTNode.bracetStatement(prefix: [.identifier(.other("foo")), .openingBracket],
                                                     body: [],
                                                     postfix: [.closingBracket])
        XCTAssertEqual(result, [expectedResult])
    }
    
    func testCommentAfterSpace() {
        let text = " //Hello World\n\n}"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        let expectedResult = [ASTNode.unkown([
                                              .whiteSpace]),
                                              .comment(Parser(string:"//Hello World").getTokens()),
                                              .unkown([.newLine, .newLine])]
        
        XCTAssertEqual(result, expectedResult)    }
    
    func testBrokenCommentWithNewLine() {
        let text = "/\n/hello world"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        XCTAssertEqual(result, [ASTNode.unkown([.op(.substract), .newLine, .op(.substract), .identifier(.other("hello")), .whiteSpace, .identifier(.other("world"))])])
    }
    
    func testMultiLineComment() {
        let text = """
/*
                This is a
                multi line comment
            */
"""
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        XCTAssertEqual(result, [ASTNode.comment(Parser(string:text).getTokens())])
    }
    
    func testInlineComment() {
        let text = "foo/*comment*/bar"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        XCTAssertEqual(result, [ASTNode.unkown([.identifier(.other("foo"))]), ASTNode.comment(Parser(string:"/*comment*/").getTokens()), ASTNode.unkown([.identifier(.other("bar"))])])
    }
    
    func testOpeningBracket() {
        let text = "{"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        XCTAssertEqual(result, [ASTNode.bracetStatement(prefix: [.openingBracket], body: [], postfix: [])])
    }
    
    func testTwoOpeningBrackets() {
        let text = "{{"
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        
        XCTAssertEqual(result, [ASTNode.bracetStatement(prefix: [.openingBracket], body: [ASTNode.bracetStatement(prefix: [.openingBracket], body: [], postfix: [])], postfix: [])])

    }
    
    func testNestedEmptyBracketStatements() {
        let text = "{{}"
        
        let tokens = Parser(string: text).getTokens()
        let result = ASTBuilder.getAST(for: tokens)
        let expectation: [ASTNode] = [.bracetStatement(prefix: [.openingBracket], body: [
            .bracetStatement(prefix: [.openingBracket], body:
                [], postfix: [.closingBracket])
            ], postfix: [])]
        
        XCTAssertEqual(result, expectation)
    }
    
    func testIntendationLevel() {
        let text = """
a{b{{
            c
            d
    }e}}f
"""
    
        let tokens = Parser(string: text).getTokens()
        let root = ASTNode.root(ASTBuilder.getAST(for: tokens))
        
        let a = text.range(of: "a")!.lowerBound.encodedOffset
        let b = text.range(of: "b")!.lowerBound.encodedOffset
        let c = text.range(of: "c")!.lowerBound.encodedOffset
        let d = text.range(of: "d")!.lowerBound.encodedOffset
        let e = text.range(of: "e")!.lowerBound.encodedOffset
        let f = text.range(of: "f")!.lowerBound.encodedOffset

        XCTAssertEqual(root.intendationLevel(at: a), 0)
        XCTAssertEqual(root.intendationLevel(at: b), 1)
        XCTAssertEqual(root.intendationLevel(at: c), 3)
        XCTAssertEqual(root.intendationLevel(at: d), 3)
        XCTAssertEqual(root.intendationLevel(at: e), 2)
        XCTAssertEqual(root.intendationLevel(at: f), 0)
    }
    
}
