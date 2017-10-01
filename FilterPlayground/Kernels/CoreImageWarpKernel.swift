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

    override class var returnType: KernelArgumentType {
        return .vec2
    }

    override class var requiredInputImages: Int {
        return 1
    }

    override class var initialSourceBody: String {
        return "\(Settings.spacingValue)return destCoord();"
    }

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
