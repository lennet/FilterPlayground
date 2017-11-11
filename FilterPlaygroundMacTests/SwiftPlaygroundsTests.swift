//
//  SwiftPlaygroundsTests.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
import CoreImage
@testable import FilterPlaygroundMac

class SwiftPlaygroundsTests: XCTestCase {

    // the first two tests are only meta tests to test the assert method

    func testCompilerDoesntCompiles() {
        let playgroundURL = SwiftPlaygroundsExportHelper.swiftPlayground(with: "var image: UIImage?")
        XCTAssertSwiftPlaygroundCompiles(url: playgroundURL, invertCondition: true)
    }

    func testCompilerCompiles() {
        let playgroundURL = SwiftPlaygroundsExportHelper.swiftPlayground(with: """
        import UIKit
        var image: UIImage?
        """)
        XCTAssertSwiftPlaygroundCompiles(url: playgroundURL)
    }
}
