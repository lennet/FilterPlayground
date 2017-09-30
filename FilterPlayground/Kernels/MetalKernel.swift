//
//  MetalKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage
import Metal
import MetalKit

class MetalKernel: Kernel {
    
    var library: MTLLibrary?
    
    var shadingLanguage: ShadingLanguage {
        return .metal
    }
    
    static func compile(source: String) -> KernelCompilerResult {
        let device = MTLCreateSystemDefaultDevice()
        do {
            let kernel = MetalKernel()
            kernel.library = try device?.makeLibrary(source: source, options: nil)
            return KernelCompilerResult.success(kernel: kernel)
        } catch let error as NSError {
            print(error.localizedDescription)
            return .failed(errors: MetalErrorParser.compileErrors(for: error.localizedDescription))
        }
    }
    
    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage? {
        return nil
    }
    
}
