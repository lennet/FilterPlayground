//
//  CoreImageWarpKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageWarpKernel: CoreImageKernel {

    override var extent: CGRect {
        switch outputSize {
        case .inherit:
            guard let input = inputImages.first else {
                return super.extent
            }

            return input.extent
        case let .custom(value):
            return value
        }
    }

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

    override func apply(with inputImages: [CIImage], attributes: [KernelArgumentValue]) -> CIImage? {
        guard let input = inputImages.first else {
            return nil
        }

        return warpKernel?.apply(extent: extent, roiCallback: { (_, rect) -> CGRect in
            rect
        }, image: input, arguments: attributes.flatMap { $0.asKernelValue })
    }
}
