//
//  ParserTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let string = "this is a test"
        let parser = Parser(string: string)
        let tokens = parser.getTokens()
        
        XCTAssertEqual(tokens, [Token.identifier(value: "this"),
                                Token.whiteSpace,
                                Token.identifier(value: "is"),
                                Token.whiteSpace,
                                Token.identifier(value: "a"),
                                Token.whiteSpace,
                                Token.identifier(value: "test")])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
