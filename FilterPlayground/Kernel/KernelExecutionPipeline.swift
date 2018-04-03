//
//  KernelExecutionPipeline.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.03.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import Foundation

class KernelExecutionPipeline {
    var errors: [KernelError] = []
    var kernel: Kernel
    var errorOutput: ([KernelError]) -> Void
    var lastCompiledSource: String?

    init(kernel: Kernel, errorOutput: @escaping ([KernelError]) -> Void) {
        self.kernel = kernel
        self.errorOutput = errorOutput
    }

    func execute(source: String) {
        if let lastCompiledSource = lastCompiledSource,
            lastCompiledSource == source {
            finishExecution()
        } else {
            errors = []
            // check for possible preconditions
            let requiredInputImages = kernel.requiredInputImages
            if kernel.inputImages.count < requiredInputImages {
                errors.append(KernelError.runtime(message: "A \(kernel.type) Kernel requires \(requiredInputImages) input image\(requiredInputImages > 1 ? "s" : "") but you only passed \(kernel.inputImages.count)"))
            }
            kernel.compile(source: source, completion: handle)
        }
        lastCompiledSource = source
    }

    func handle(compilerResult: KernelCompilerResult) {
        switch compilerResult {
        case let .success(warnings: errors):
            self.errors.append(contentsOf: errors)
            break
        case let .failed(errors: errors):
            self.errors.append(contentsOf: errors)
            break
        }
        finishExecution()
    }

    func renderIfPossible() {
        guard !errors.containsError else {
            return
        }
        DispatchQueue.main.async {
            self.kernel.render()
        }
    }

    func finishExecution() {
        defer {
            DispatchQueue.main.async {
                self.errorOutput(self.errors)
            }
        }
        renderIfPossible()
    }
}
