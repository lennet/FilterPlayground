//
//  DataBindingContextTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class MockDataBindingObserver: DataBindingObserver {

    var mockedBindingType: DataBinding = .time
    var observedBinding: DataBinding {
        return mockedBindingType
    }

    var id: String

    init(id: String) {
        self.id = id
    }

    var valueChangedCalled = false

    func valueChanged(value _: Any) {
        valueChangedCalled = true
    }
}

class DataBindingContextTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataBindingContext.shared.reset()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddObserver() {
        let name = "foo"
        let mockObserver = MockDataBindingObserver(id: name)
        XCTAssertNil(DataBindingContext.shared.observer(with: name))

        DataBindingContext.shared.add(observer: mockObserver, with: name)
        let result = DataBindingContext.shared.observer(with: name) as? MockDataBindingObserver
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.id, name)
    }

    func testRemoveObserver() {
        let name = "foo"
        let mockObserver = MockDataBindingObserver(id: name)
        XCTAssertNil(DataBindingContext.shared.observer(with: name))

        DataBindingContext.shared.add(observer: mockObserver, with: name)
        XCTAssertNotNil(DataBindingContext.shared.observer(with: name))

        DataBindingContext.shared.removeObserver(with: name)
        XCTAssertNil(DataBindingContext.shared.observer(with: name))
    }

    func testOverrideObserver() {
        let foo = "foo"
        let fooMockObserver = MockDataBindingObserver(id: foo)

        let bar = "bar"
        let barMockObserver = MockDataBindingObserver(id: bar)
        XCTAssertNil(DataBindingContext.shared.observer(with: foo))
        XCTAssertNil(DataBindingContext.shared.observer(with: bar))

        DataBindingContext.shared.add(observer: fooMockObserver, with: foo)
        let firstResult = DataBindingContext.shared.observer(with: foo) as! MockDataBindingObserver
        XCTAssertEqual(firstResult.id, foo)
        XCTAssertNil(DataBindingContext.shared.observer(with: bar))

        DataBindingContext.shared.add(observer: barMockObserver, with: foo)
        let secondResult = DataBindingContext.shared.observer(with: foo) as! MockDataBindingObserver
        XCTAssertEqual(secondResult.id, bar)
        XCTAssertNil(DataBindingContext.shared.observer(with: bar))
    }

    func testReset() {
        let name = "foo"
        let mockObserver = MockDataBindingObserver(id: name)
        XCTAssertNil(DataBindingContext.shared.observer(with: name))

        DataBindingContext.shared.add(observer: mockObserver, with: name)
        XCTAssertNotNil(DataBindingContext.shared.observer(with: name))

        DataBindingContext.shared.reset()
        XCTAssertNil(DataBindingContext.shared.observer(with: name))
    }

    func testObserverCalled() {
        let foo = "foo"
        let fooMockObserver = MockDataBindingObserver(id: foo)

        let bar = "bar"
        let barMockObserver = MockDataBindingObserver(id: bar)

        DataBindingContext.shared.add(observer: fooMockObserver, with: foo)
        DataBindingContext.shared.add(observer: barMockObserver, with: bar)

        XCTAssertFalse(fooMockObserver.valueChangedCalled)
        XCTAssertFalse(barMockObserver.valueChangedCalled)

        DataBindingContext.shared.emit(value: 5, for: barMockObserver.mockedBindingType)

        XCTAssertTrue(fooMockObserver.valueChangedCalled)
        XCTAssertTrue(barMockObserver.valueChangedCalled)
    }

    func testObserverNotCalledForWrongType() {
        let foo = "foo"
        let fooMockObserver = MockDataBindingObserver(id: foo)

        let bar = "bar"
        let barMockObserver = MockDataBindingObserver(id: bar)
        barMockObserver.mockedBindingType = .camera

        DataBindingContext.shared.add(observer: fooMockObserver, with: foo)
        DataBindingContext.shared.add(observer: barMockObserver, with: bar)

        XCTAssertFalse(fooMockObserver.valueChangedCalled)
        XCTAssertFalse(barMockObserver.valueChangedCalled)

        DataBindingContext.shared.emit(value: 5, for: fooMockObserver.mockedBindingType)

        XCTAssertTrue(fooMockObserver.valueChangedCalled)
        XCTAssertFalse(barMockObserver.valueChangedCalled)
    }
}
