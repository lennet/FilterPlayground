//
//  CIFilterHelperTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
import CoreImage
@testable import FilterPlaygroundMac

class CIFilterHelperTests: XCTestCase {
    
    // the first two tests are only meta tests to test the assert method
    
    func testCompilerDoesntCompiles() {
        XCTAssertSwiftCompiles(source: "var image: UIImage?", invertCondition: true)
    }
    
    func testCompilerCompiles() {
        XCTAssertSwiftCompiles(source: """
        import UIKit
        var image: UIImage?
        """)
    }
    
    func testWarpFilter() {
        let source: String = CIFilterHelper.cifilter(with: "", type: .warp, arguments: [], name: "testWarp")
        XCTAssertSwiftCompiles(source: source)
    }
    
    func testWarpFilterWithArguments() {
        let arguments = [KernelAttribute(name: "foo", type: .color, value: .color(1, 1, 1, 1)),
                         KernelAttribute(name: "bar", type: .vec2, value: .vec2(1, 1)),
                         KernelAttribute(name: "test", type: .sample, value: .sample(CIImage(color: .black)))]
        let source: String = CIFilterHelper.cifilter(with: "", type: .warp, arguments:arguments, name: "testWarp")
        XCTAssertSwiftCompiles(source: source)
    }
    
    func testBlendFilter() {
        let source: String = CIFilterHelper.cifilter(with: "", type: .blend, arguments: [KernelAttribute(name: "foo", type: .sample, value: .sample(CIImage(color: .black))), KernelAttribute(name: "bar", type: .sample, value: .sample(CIImage(color: .black)))], name: "testBlend")
        XCTAssertSwiftCompiles(source: source)
    }
    
    func testColorFilter() {
        let source: String = CIFilterHelper.cifilter(with: "", type: .color, arguments: [KernelAttribute(name: "test", type: .sample, value: .sample(CIImage(color: .black)))], name: "testColor")
        XCTAssertSwiftCompiles(source: source)
        
    }
    
    func testNormalFilter() {
        let source: String = CIFilterHelper.cifilter(with: "", type: .normal, arguments: [], name: "testNormal")
        XCTAssertSwiftCompiles(source: source)
    }
    
}
