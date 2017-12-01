//
//  KernelCompilerResult.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelCompilerResult {
    /// errors could contain warnings
    case success(warnings: [KernelError])
    case failed(errors: [KernelError])
}
