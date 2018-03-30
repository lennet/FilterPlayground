//
//  RendererTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class RendererTests: XCTestCase {
    func testRenderAsPlainText() {
        let string = "this is a test 50.0 and 50"
        let tokenizer = Tokenizer(string: string)
        let tokens = tokenizer.getTokens()
        XCTAssertEqual(Renderer.renderAsPlainText(tokens: tokens), string)
    }
}
