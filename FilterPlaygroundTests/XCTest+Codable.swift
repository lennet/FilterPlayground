//
//  XCTest+Codable.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 26.02.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import XCTest

extension XCTest {
    func XCTAssertEncodeDecode<T>(_ codable: T, file: StaticString = #file, line: UInt = #line) where T: Equatable, T: Codable {
        do {
            let encoded = try JSONEncoder().encode(codable)
            let decoded = try JSONDecoder().decode(T.self, from: encoded)
            XCTAssertEqual(codable, decoded)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
}
