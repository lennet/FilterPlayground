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

    override func compile(source: String) -> Bool {
        if let kernel = CIWarpKernel(source: source) {
            warpKernel = kernel
            return true
        }
        return false
    }

    override func apply(with inputImages: [CIImage], attributes: [KernelAttributeValue]) -> CIImage? {
        guard let input = inputImages.first else {
            return nil
        }

        return warpKernel?.apply(extent: input.extent, roiCallback: { (_, rect) -> CGRect in
            rect
        }, image: input, arguments: attributes.flatMap{$0.asKernelValue})
    }
}
