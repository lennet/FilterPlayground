//
//  CIFilterHelperTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage
@testable import FilterPlaygroundMac
import XCTest

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
        let source: String = CIFilterExportHelper.cifilter(with: "", type: .coreimagewarp, arguments: [], name: "testWarp")
        XCTAssertSwiftCompiles(source: source)
    }

    func testWarpFilterWithArguments() {
        let arguments: [KernelArgument] = [
            KernelArgument(index: 0, name: "foo", type: .color, value: .color(1, 1, 1, 1)),
            KernelArgument(index: 1, name: "bar", type: .vec2, value: .vec2(1, 1)),
            KernelArgument(index: 2, name: "test", type: .sample, value: .sample(CIImage(color: .black))),
        ]
        let source: String = CIFilterExportHelper.cifilter(with: "", type: .coreimagewarp, arguments: arguments, name: "testWarp")
        XCTAssertSwiftCompiles(source: source)
    }

    func testBlendFilter() {
        let arguments = [KernelArgument(index: 0, name: "foo", type: .sample, value: .sample(CIImage(color: .black))), KernelArgument(index: 1, name: "bar", type: .sample, value: .sample(CIImage(color: .black)))]

        let source: String = CIFilterExportHelper.cifilter(with: "", type: .coreimageblend, arguments: arguments, name: "testBlend") as String
        XCTAssertSwiftCompiles(source: source)
    }

    func testColorFilter() {
        let source: String = CIFilterExportHelper.cifilter(with: "", type: .coreimagecolor, arguments: [KernelArgument(index: 0, name: "test", type: .sample, value: .sample(CIImage(color: .black)))], name: "testColor")
        XCTAssertSwiftCompiles(source: source)
    }

    func testNormalFilter() {
        let source: String = CIFilterExportHelper.cifilter(with: "", type: .coreimage, arguments: [], name: "testNormal")
        XCTAssertSwiftCompiles(source: source)
    }
}
