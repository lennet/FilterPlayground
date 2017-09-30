//
//  Kernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

protocol Kernel: class {

    var shadingLanguage: ShadingLanguage { get }
    
    static func compile(source: String) -> Kernel?

    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage?
}

class GeneralKernel: Kernel {
    
    var shadingLanguage: ShadingLanguage {
        return .coreimage
    }
    
    var kernel: CIKernel?

    static func compile(source: String) -> Kernel? {
        if let kernel = CIKernel(source: source) {
            let result = GeneralKernel()
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

class BlendKernel: Kernel {
    
    var shadingLanguage: ShadingLanguage {
        return .coreimage
    }

    var kernel: CIBlendKernel?

    static func compile(source: String) -> Kernel? {
        if let kernel = CIBlendKernel(source: source) {
            let result = BlendKernel()
            result.kernel = kernel
            return result
        }
        return nil
    }

    func apply(with inputImages: [CIImage], attributes _: [Any]) -> CIImage? {
        guard let first = inputImages.first,
            let second = inputImages.last,
            inputImages.count == 2 else {
            return nil
        }

        return kernel?.apply(foreground: first, background: second)
    }
}
