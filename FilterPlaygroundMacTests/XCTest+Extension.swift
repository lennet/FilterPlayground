//
//  XCTest+Extension.swift
//  FilterPlaygroundMacTests
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import XCTest

extension XCTest {
    
    func XCTAssertSwiftCompiles(source: String, invertCondition: Bool = false, file: StaticString = #file, line: UInt = #line) {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("tmp.swift")
        try? source.data(using: .utf8)?.write(to: tmpURL, options: .atomic)
        XCTAssertSwiftCompiles(url: tmpURL, invertCondition: invertCondition, file: file, line: line, source: source)
    }
    
    func XCTAssertSwiftCompiles(url: URL, invertCondition: Bool = false, file: StaticString = #file, line: UInt = #line, source: String? = nil) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["xcrun", "-sdk", "iphoneos", "swiftc", "-target", "arm64-apple-ios11.0", url.path]
        
        let pipe = Pipe()
        task.standardError = pipe
        
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus == 0 && invertCondition {
            XCTFail("Code compiles", file: file, line: line)
        } else if task.terminationStatus == 1 && !invertCondition {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let error = (String(data: data, encoding: .utf8) ?? "Unkown error").replacingOccurrences(of: url.path, with: "")
            let message = """
            failed to compile:
            ------------------------------
            \(source ?? "")
            ------------------------------
            with error log:
            ------------------------------
            \(error)
            ------------------------------
            """
            XCTFail(message, file: file, line: line)
        }
    }
    
    func XCTAssertSwiftPlaygroundCompiles(url: URL, invertCondition: Bool = false, file: StaticString = #file, line: UInt = #line) {
        let contentsURL = url.appendingPathComponent("/Contents.swift")
        let source = try! String(contentsOf: contentsURL)
        XCTAssertSwiftCompiles(url: contentsURL, invertCondition: invertCondition, file: file, line: line, source: source)
    }
    
}
