//
//  CoreImageBlendKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageBlendKernel: CoreImageKernel {

    var blendKernel: CIBlendKernel?

    override class func compile(source: String) -> Kernel? {
        if let kernel = CIBlendKernel(source: source) {
            let result = CoreImageBlendKernel()
            result.blendKernel = kernel
            return result
        }
        return nil
    }

    override func apply(with inputImages: [CIImage], attributes _: [Any]) -> CIImage? {
        guard let first = inputImages.first,
            let second = inputImages.last,
            inputImages.count == 2 else {
            return nil
        }

        return blendKernel?.apply(foreground: first, background: second) }
}
