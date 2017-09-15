//
//  KernelCompiler.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelCompilerResult {
    case success(kernel: Kernel)
    case failed(errors: [KernelError])
}

class KernelCompiler<T: Kernel> {

    private init() {}

    class func compile(source: String) -> KernelCompilerResult {
        let errorHelper = ErrorHelper()
        if let kernel = T.compile(source: source) {
            return KernelCompilerResult.success(kernel: kernel)
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: ErrorParser.compileErrors(for: errorString))
        }
        return .failed(errors: [KernelError.compile(lineNumber: -1, characterIndex: -1, type: "Error", message: "Unkown Error. Please check your code.", note: nil)])
    }
}
