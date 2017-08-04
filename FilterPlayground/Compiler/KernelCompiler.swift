//
//  KernelCompiler.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelCompilerResult<T: Kernel> {
    case success(kernel: T)
    case failed(errors: [CompilerError])
}

class KernelCompiler<T: Kernel> {

    private init() {}
    
    class func compile(source: String) -> KernelCompilerResult<T> {
        let errorHelper = ErrorHelper()
        if let kernel = T.compile(source: source) {
            return KernelCompilerResult<T>.success(kernel: kernel as! T)
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: ErrorParser.getErrors(for: errorString))
        }
        // todo add unkown errors
        return .failed(errors: [])
    }
    
}
