//
//  KernelArgumentControllerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 03.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class KernelArgumentControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testInsertFromSource() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, KernelArgumentSource.ui([.reload(0)]))
            exp.fulfill()
        }
        XCTAssertEqual(kernel.arguments.count, 0)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        let argumentDefinition = KernelDefinitionArgument(index: 0, name: "foo", type: .color)
        controller.updateArgumentsFromCode(arguments: [argumentDefinition])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "foo")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .color)

        wait(for: [exp], timeout: 0.5)
    }

    func testRemoveFromSource() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, KernelArgumentSource.ui([]))
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentsFromCode(arguments: [])
        XCTAssertEqual(kernel.arguments.count, 0)

        wait(for: [exp], timeout: 0.5)
    }

    func testRenameFromSource() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let updatedArgument = KernelArgument(index: 0, name: "bar", type: .color, value: .color(0, 0, 0, 0))
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, KernelArgumentSource.ui([.update(0, updatedArgument)]))
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        let argumentDefinition = KernelDefinitionArgument(index: 0, name: "bar", type: .color)
        controller.updateArgumentsFromCode(arguments: [argumentDefinition])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "bar")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .color)

        wait(for: [exp], timeout: 0.5)
    }

    func testChangeTypeFromSource() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { _ in
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        let argumentDefinition = KernelDefinitionArgument(index: 0, name: "foo", type: .float)
        controller.updateArgumentsFromCode(arguments: [argumentDefinition])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "foo")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .float)

        wait(for: [exp], timeout: 0.5)
    }

    func testInsertFromUI() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, .code)
            exp.fulfill()
        }
        XCTAssertEqual(kernel.arguments.count, 0)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        let argument = KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))
        controller.updateArgumentsFromUI(arguments: [argument])
        XCTAssertEqual(kernel.arguments.count, 1)
        let newArgument = kernel.arguments.first!
        XCTAssertEqual(newArgument.name, "foo")
        XCTAssertEqual(newArgument.index, 0)
        XCTAssertEqual(newArgument.type, .color)

        wait(for: [exp], timeout: 0.5)
    }

    func testRemoveFromUI() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, .code)
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentsFromUI(arguments: [])
        XCTAssertEqual(kernel.arguments.count, 0)

        wait(for: [exp], timeout: 0.5)
    }

    func testRenameFromUI() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, .code)
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentsFromUI(arguments: [KernelArgument(index: 0, name: "bar", type: .color, value: .color(0, 0, 0, 0))])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "bar")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .color)

        wait(for: [exp], timeout: 0.5)
    }

    func testChangeTypeFromUI() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, .code)
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentsFromUI(arguments: [KernelArgument(index: 0, name: "foo", type: .float, value: .float(0))])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "foo")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .float)

        wait(for: [exp], timeout: 0.5)
    }

    func testChangeValueFromUI() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertEqual(source, .render)
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentsFromUI(arguments: [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 1))])
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "foo")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .color)
        XCTAssertEqual(argument.value, .color(0, 0, 0, 1))

        wait(for: [exp], timeout: 0.5)
    }

    func testUpdateArgumentFromObserver() {
        let kernel = MockKernel()
        let exp = expectation(description: "waiting for callback")
        exp.expectedFulfillmentCount = 2
        let callback: (KernelArgumentSource) -> Void = { source in
            XCTAssertNotEqual(source, .code)
            exp.fulfill()
        }
        kernel.arguments = [KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 0))]
        XCTAssertEqual(kernel.arguments.count, 1)
        let controller = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: callback)
        controller.updateArgumentFromObserver(argument: KernelArgument(index: 0, name: "foo", type: .color, value: .color(0, 0, 0, 1)))
        XCTAssertEqual(kernel.arguments.count, 1)
        let argument = kernel.arguments.first!
        XCTAssertEqual(argument.name, "foo")
        XCTAssertEqual(argument.index, 0)
        XCTAssertEqual(argument.type, .color)
        XCTAssertEqual(argument.value, .color(0, 0, 0, 1))

        wait(for: [exp], timeout: 0.5)
    }
}
