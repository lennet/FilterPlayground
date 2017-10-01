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

    let device: MTLDevice?

    required init() {
        device = MTLCreateSystemDefaultDevice()
    }

    static var requiredInputImages: Int {
        return 0
    }

    static var supportedArguments: [KernelArgumentType] {
        // todo
        return []
    }

    var library: MTLLibrary?

    class var shadingLanguage: ShadingLanguage {
        return .metal
    }

    func compile(source: String) -> KernelCompilerResult {
        var errors: [KernelError] = []

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        device?.makeLibrary(source: source, options: nil, completionHandler: { lib, error in
            self.library = lib
            if let error = error as? MTLLibraryError {
                errors = MetalErrorParser.compileErrors(for: error.localizedDescription)
                print(error)
            }
            dispatchGroup.leave()
        })

        dispatchGroup.wait()
        if library == nil {
            return .failed(errors: errors)
        }
        return .success(errors: errors)
    }

    static func initialSource(with name: String) -> String {
        return """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void \(name)(
        texture2d<float, access::read> inTexture [[texture(0)]],
        texture2d<float, access::write> outTexture [[texture(1)]],
        uint2 gid [[thread_position_in_grid]])
        
        {
        
        
        }
        """
    }

    func apply(with _: [CIImage], attributes _: [Any]) -> CIImage? {
        return nil
    }
}
