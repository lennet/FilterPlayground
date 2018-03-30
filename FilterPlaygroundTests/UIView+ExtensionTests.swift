//
//  UIView+ExtensionTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 02.12.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class UIView_ExtensionTests: XCTestCase {
    func testRemoveAllSubviews() {
        let view = UIView()
        view.addSubview(UIView())
        view.addSubview(UIView())
        view.addSubview(UIView())
        view.addSubview(UIView())

        XCTAssertEqual(view.subviews.count, 4)
        view.removeAllSubViews()
        XCTAssertEqual(view.subviews.count, 0)
    }
}
