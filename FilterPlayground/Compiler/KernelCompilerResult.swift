//
//  KernelCompilerResult.swift
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
