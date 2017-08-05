//
//  RendererTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class RendererTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRenderAsPlainText() {
        let string = "this is a test 50.0 and 50"
        let parser = Parser(string: string)
        let tokens = parser.getTokens()
        XCTAssertEqual(Renderer.renderAsPlainText(tokens: tokens), string)
    }
    
}
