//
//  CoreImageWarpKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageWarpKernel: CoreImageKernel {

    var warpKernel: CIWarpKernel?

    override class func compile(source: String) -> Kernel? {
        if let kernel = CIWarpKernel(source: source) {
            let result = CoreImageWarpKernel()
            result.warpKernel = kernel
            return result
        }
        return nil
    }

    override func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage? {
        guard let input = inputImages.first else {
            return nil
        }

        return warpKernel?.apply(extent: input.extent, roiCallback: { (_, rect) -> CGRect in
            rect
        }, image: input, arguments: attributes)
    }
}
