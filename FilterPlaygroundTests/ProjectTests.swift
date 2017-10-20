//
//  DocumentTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 17.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class ProjectTests: XCTestCase {

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
    
    func testSaveInputImages() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsPath.appendingPathComponent("\(Date()).filterplayground")
        
        let expectation = XCTestExpectation(description: "Waiting for file creation")
        
        let document = Project(fileURL: url, type: .coreimagewarp)
        document.save(to: url, for: .forCreating) { _ in
            XCTAssertEqual(document.metaData.inputImages.filter{ $0.image != nil }.count, 0)
            document.metaData.inputImages[0].image = #imageLiteral(resourceName: "DefaultImage")
            document.close(completionHandler: { _ in
                let document2 = Project(fileURL: url)
                document2.open(completionHandler: { _ in
                    XCTAssertEqual(document.metaData.inputImages.filter{ $0.image != nil }.count, 1)
                    expectation.fulfill()
                })
            })
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
}
