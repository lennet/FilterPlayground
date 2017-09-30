//
//  DocumentTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 17.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class DocumentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddResources() {
        let document = Project(fileURL: URL(fileURLWithPath: ""), type: .coreimagewarp)
        XCTAssertEqual(document.getAllResources().count, 0)

        let data = Data()
        document.addResource(for: "test", with: data)

        let resources = document.getAllResources()
        XCTAssertEqual(resources.count, 1)
        XCTAssertEqual(resources.first?.name ?? "", "test")
    }

    func testRemoveResource() {
        let document = Project(fileURL: URL(fileURLWithPath: ""), type: .coreimagewarp)

        let data = Data()
        document.addResource(for: "test", with: data)
        XCTAssertEqual(document.getAllResources().count, 1)

        document.removeResource(for: "test")
        XCTAssertEqual(document.getAllResources().count, 0)
    }

    func testRenameResource() {
        let document = Project(fileURL: URL(fileURLWithPath: ""), type: .coreimagewarp)

        let data = Data()
        document.addResource(for: "test", with: data)
        XCTAssertEqual(document.getAllResources().count, 1)

        document.renameResouce(for: "test", with: "foo")
        let resources = document.getAllResources()
        XCTAssertEqual(resources.count, 1)
        XCTAssertEqual(resources.first?.name ?? "", "foo")
    }
}
