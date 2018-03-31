//
//  ErrorHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class ErrorHelper {
    let fileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("ErrorLog\(Date())")

    init() {
        redirectSTDErr()
    }

    deinit {
        deleteLogs()
    }

    private func redirectSTDErr() {
        freopen(fileURL.path.cString(
            using: .ascii)!,
        "a+",
        stderr)
    }

    func errorString() -> String? {
        if let result = try? String(contentsOf: fileURL),
            !result.isEmpty {
            print(result)
            return result
        }
        return nil
    }

    func deleteLogs() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
