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
