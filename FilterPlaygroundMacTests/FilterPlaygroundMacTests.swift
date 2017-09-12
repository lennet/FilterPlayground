//
//  FilterPlaygroundMacTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
import CoreImage
@testable import FilterPlaygroundMac

extension XCTest {
    
    func XCTAssertSwiftCompiles(source: String, invertCondition: Bool = false, file: StaticString = #file, line: UInt = #line) {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("tmp.swift")
        try? source.data(using: .utf8)?.write(to: tmpURL, options: .atomic)
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["xcrun", "-sdk", "iphoneos", "swiftc", "-target", "arm64-apple-ios11.0", tmpURL.path]
        task.launch()
        task.waitUntilExit()
        XCTAssertEqual(task.terminationStatus, invertCondition ? 1 : 0,
                       file: file, line: line)
    }
    
}

class FilterPlaygroundMacTests: XCTestCase {
    
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
    
}
