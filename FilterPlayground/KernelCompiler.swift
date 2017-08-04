//
//  KernelCompiler.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum KernelCompilerResult {
    case success(kernel: CIWarpKernel)
    case failed(errors: [CompilerError])
}

class KernelCompiler {

    private init() {}
    
    class func compile(source: String) -> KernelCompilerResult {
        let errorHelper = ErrorHelper()
        if let kernel = CIWarpKernel(source: source) {
            return .success(kernel: kernel)
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: ErrorParser.getErrors(for: errorString))
        }
        // todo add unkown errors
        return .failed(errors: [])
    }
    
}
