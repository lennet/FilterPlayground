//
//  KernelDescriptorTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class KernelDescriptorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrefixColorKernel() {
        let descriptor = KernelDescriptor(name: "foo", type: .color, attributes: [KernelAttribute(name: "bar", type: .vec2, value: nil), KernelAttribute(name: "bar2", type: .vec3, value: nil)])
        XCTAssertEqual(descriptor.prefix, "kernel vec4 foo(vec2 bar, vec3 bar2) {\n")
    }
    
    func testPrefixWarpKernel() {
        let descriptor = KernelDescriptor(name: "foo", type: .warp, attributes: [KernelAttribute(name: "bar", type: .vec2, value: nil), KernelAttribute(name: "bar2", type: .vec3, value: nil)])
        XCTAssertEqual(descriptor.prefix, "kernel vec2 foo(vec2 bar, vec3 bar2) {\n")
    }

}
