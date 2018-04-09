//
//  FloatPickerObjectTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 08.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class FloatPickerObjectTests: XCTestCase {
    func testNoInput() {
        let object = FloatPickerObject()
        XCTAssertEqual(object.floatRepresentation, 0)
    }

    func test24() {
        var object = FloatPickerObject()
        object.add(input: .digit(2))
        object.add(input: .digit(4))
        XCTAssertEqual(object.floatRepresentation, 24)
    }

    func test24dot0() {
        var object = FloatPickerObject()
        object.add(input: .digit(2))
        object.add(input: .digit(4))
        object.add(input: .dot)
        object.add(input: .digit(0))
        XCTAssertEqual(object.floatRepresentation, 24)
    }

    func test24dot15() {
        var object = FloatPickerObject()
        object.add(input: .digit(2))
        object.add(input: .digit(4))
        object.add(input: .dot)
        object.add(input: .digit(1))
        object.add(input: .digit(5))
        XCTAssertEqual(object.floatRepresentation, 24.15)
    }

    func test19dot94dot3() {
        var object = FloatPickerObject()
        object.add(input: .digit(1))
        object.add(input: .digit(9))
        object.add(input: .dot)
        object.add(input: .digit(9))
        object.add(input: .digit(4))
        object.add(input: .digit(3))
        XCTAssertEqual(object.floatRepresentation, 19.943)
    }

    func testInit32() {
        let object = FloatPickerObject(floatLiteral: 32)
        XCTAssertEqual(object.floatRepresentation, 32)
    }

    func testInit0() {
        let object = FloatPickerObject(floatLiteral: 0)
        XCTAssertEqual(object.floatRepresentation, 0)
    }

    func testinit76dot39() {
        let object = FloatPickerObject(floatLiteral: 76.39)
        XCTAssertEqual(object.floatRepresentation, 76.39)
    }

    func testRemoveLastNumber() {
        var object = FloatPickerObject(floatLiteral: 76.39)
        object.removeLastInput()
        XCTAssertEqual(object.floatRepresentation, 76.3)
    }

    func testRemoveDot() {
        var object = FloatPickerObject(floatLiteral: 76.0)
        object.removeLastInput()
        object.removeLastInput()
        XCTAssertEqual(object.floatRepresentation, 76)
    }

    func testRemoveLastFromEmptyObject() {
        var object = FloatPickerObject()
        object.removeLastInput()
        XCTAssertEqual(object.floatRepresentation, 0)
    }

    func testStringRepresentation() {
        let object = FloatPickerObject(floatLiteral: 123.456)
        XCTAssertEqual(object.stringRepresentation, "123.456")
    }
}
