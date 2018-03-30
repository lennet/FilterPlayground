//
//  TouchDataBindingEmitterTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 19.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class TouchDataBindingEmitterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DataBindingContext.shared.reset()
    }

    func testValueChanged() {
        let observer = MockDataBindingObserver(id: "foo")
        observer.mockedBindingType = .touch
        (TouchDataBindingEmitter.shared as! TouchDataBindingEmitter).detectedTouch(point: .zero)
        XCTAssertFalse(observer.valueChangedCalled)
        DataBindingContext.shared.add(observer: observer, with: observer.id)
        (TouchDataBindingEmitter.shared as! TouchDataBindingEmitter).detectedTouch(point: .zero)
        XCTAssertTrue(observer.valueChangedCalled)
    }
}
