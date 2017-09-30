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
        
        let kernel = MetalKernel()
        var errors: [KernelError] = []
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        device?.makeLibrary(source: source, options: nil, completionHandler: { (lib, error) in
            kernel.library = lib
            if let error = error as? MTLLibraryError {
                errors =  MetalErrorParser.compileErrors(for: error.localizedDescription)
                print(error)
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.wait()
        if kernel.library == nil {
            return .failed(errors: errors)
        }
        return .success(kernel: kernel, errors: errors)
    }
    
    class var initialSource: String {
        return """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void untitled(
        texture2d<float, access::read> inTexture [[texture(0)]],
        texture2d<float, access::write> outTexture [[texture(1)]],
        uint2 gid [[thread_position_in_grid]])
        
        {
        
        
        }
        """
    }
    
    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage? {
        return nil
    }
    
}
