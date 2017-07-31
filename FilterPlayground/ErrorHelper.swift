//
//  ErrorHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ErrorHelper {

    let filePath: String = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        let fileName = "/ErrorLog\(Date())"
        return documentsPath + fileName
    }()
    
    init() {
        redirectSTDErr()
    }
    
    deinit {
        deleteLogs()
    }
    
    func redirectSTDErr() {
        freopen(filePath.cString(
            using: .ascii)!,
                "a+",
                stderr)
        print(filePath)
    }
    
    func parseError() -> String? {
        let url = URL(fileURLWithPath: filePath)
        return try? String(contentsOf: url)
    }
    
    func deleteLogs() {
        try? FileManager.default.removeItem(atPath: filePath)
    }
}
