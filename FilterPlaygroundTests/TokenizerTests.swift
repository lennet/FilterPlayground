
//
//  TokenizerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class TokenizerTests: XCTestCase {
    func testTokenizeOperator() {
        let string = "+"

        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.op(.add), tokenizer.nextToken()!)
    }

    func testTokenizeFloat() {
        let string = "50.0"

        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.float(string), tokenizer.nextToken()!)
    }

    func testFloatBeforeLinebreak() {
        let string = "50.0\n"

        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.float("50.0"), tokenizer.nextToken()!)
    }

    func testTokenizeFloat2() {
        let string = "50"

        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.float(string), tokenizer.nextToken()!)
    }

    func testTokenizeFloatStartingWithZero() {
        let string = "050"

        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.float(string), tokenizer.nextToken()!)
    }

    func testTokenizeWhiteSpace() {
        let string = " "
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.whiteSpace, tokenizer.nextToken()!)
    }

    func testTokenizeNewLine() {
        let string = "\n"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.newLine, tokenizer.nextToken()!)
    }

    func testTokenizeIdentifier() {
        let string = "test"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.identifier(.other(string)), tokenizer.nextToken()!)
    }

    func testTokenizeType() {
        let string = "vec2"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.identifier(.type(.vec2)), tokenizer.nextToken()!)
    }

    func testTokenizeTab() {
        let string = "\t"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.tab, tokenizer.nextToken()!)
    }

    func testTokenizeDateString() {
        let string = "30.07.17"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.identifier(.other("30")), tokenizer.nextToken()!)
    }

    func testTokenizeSampleAttribute() {
        let string = "__sample"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.identifier(.type(.sample)), tokenizer.nextToken()!)
    }

    func testFloatAfterBracket() {
        let string = "(float"
        let tokenizer = Tokenizer(string: string)
        XCTAssertEqual(Token.identifier(.other("(")), tokenizer.nextToken()!)
        XCTAssertEqual(Token.identifier(.type(.float)), tokenizer.nextToken()!)
    }
}
