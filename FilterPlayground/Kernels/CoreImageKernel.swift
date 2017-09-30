//
//  CoreImageKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageKernel: Kernel {
    
    var shadingLanguage: ShadingLanguage {
        return .coreimage
    }
    
    var kernel: CIKernel?
    
    static func compile(source: String) -> KernelCompilerResult {
        let errorHelper = ErrorHelper()
        if let kernel: Kernel = compile(source: source) {
            return KernelCompilerResult.success(kernel: kernel)
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: CoreImageErrorParser.compileErrors(for: errorString))
        }
        return .failed(errors: [KernelError.compile(lineNumber: -1, characterIndex: -1, type: "Error", message: "Unkown Error. Please check your code.", note: nil)])
        
    }
    
    class func compile(source: String) -> Kernel? {
        if let kernel = CIKernel(source: source) {
            let result = CoreImageKernel()
            result.kernel = kernel
            return result
        }
        return nil
    }
    
    func apply(with _: [CIImage], attributes: [Any]) -> CIImage? {
        let arguments: [Any] = attributes
        return kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), roiCallback: { (_, rect) -> CGRect in
            rect
        }, arguments: arguments)
    }
    
}
