//
//  SavingDocumentTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest
@testable import FilterPlayground

class SavingDocumentTests: XCTestCase {
    
    var url: URL!
    
    override func setUp() {
        super.setUp()
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = documentsPath.appendingPathComponent("\(Date()).CIKernel")
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
        super.tearDown()
    }
    
    func testSaveText() {
//        let text = "Hello World"
//        let expectation = XCTestExpectation(description: "Waiting for file creation")
//        
//        let document = Document(fileURL: url)
//        document.save(to: url, for: .forCreating) { (_) in
//            document.source = text
//            document.close(completionHandler: { (_) in
//                let document2 = Document(fileURL: self.url)
//                document2.open(completionHandler: { (_) in
//                    XCTAssertEqual(document2.source, text)
//                    expectation.fulfill()
//                })
//            })
//        }
//        
//        wait(for: [expectation], timeout: 5)
    }
    

}
