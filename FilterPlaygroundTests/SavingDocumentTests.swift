//
//  SavingDocumentTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

class SavingDocumentTests: XCTestCase {
    var url: URL!

    override func setUp() {
        super.setUp()
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = documentsPath.appendingPathComponent("\(Date()).CIKernel")
        sleep(1)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
        sleep(1)
        super.tearDown()
    }

    func testSaveText() {
        let text = "Hello World"
        let attribute = KernelArgument(index: 0, name: "test", type: .float, value: .float(50))
        let expectation = XCTestExpectation(description: "Waiting for file creation")

        let document = Project(fileURL: url)

        document.save(to: url, for: .forCreating) { _ in
            document.source = text
            document.metaData.arguments = [attribute]
            DispatchQueue.main.async {
                document.close(completionHandler: { _ in
                    let document2 = Project(fileURL: self.url)
                    document2.open(completionHandler: { _ in
                        XCTAssertEqual(document2.source, text)
                        XCTAssertNotNil(document2.metaData.arguments.first)
                        expectation.fulfill()
                    })
                })
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSaveImage() {
        let text = "Hello World"
        let attribute = KernelArgument(index: 0, name: "test", type: .sample, value: KernelArgumentType.sample.defaultValue)
        let expectation = XCTestExpectation(description: "Waiting for file creation")

        let document = Project(fileURL: url)
        document.save(to: url, for: .forCreating) { _ in
            document.source = text
            document.metaData.arguments = [attribute]
            document.close(completionHandler: { _ in
                let document2 = Project(fileURL: self.url)
                document2.open(completionHandler: { _ in
                    XCTAssertEqual(document2.source, text)
                    XCTAssertNotNil(document2.metaData.arguments.first)
                    XCTAssertEqual(document2.getAllResources().count, 1)
                    expectation.fulfill()
                })
            })
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSaveMetalProject() {
        let text = "Hello World"
        let attribute = KernelArgument(index: 0, name: "test", type: .float, value: .float(50))
        let expectation = XCTestExpectation(description: "Waiting for file creation")

        let document = Project(fileURL: url, type: .metal)
        document.save(to: url, for: .forCreating) { _ in
            document.source = text
            document.metaData.arguments = [attribute]
            DispatchQueue.main.async {
                document.close(completionHandler: { _ in
                    let document2 = Project(fileURL: self.url)
                    document2.open(completionHandler: { _ in
                        XCTAssertEqual(document2.source, text)
                        XCTAssertNotNil(document2.metaData.arguments.first)
                        expectation.fulfill()
                    })
                })
            }
        }

        wait(for: [expectation], timeout: 5)
    }
}
