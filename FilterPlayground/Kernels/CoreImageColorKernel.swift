//
//  CoreImageColorKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageColorKernel: CoreImageKernel {

    var colorKernel: CIColorKernel?

    override class var requiredArguments: [KernelArgumentType] {
        return [.sample]
    }

    override class var initialArguments: String {
        return "\(KernelArgumentType.sample.rawValue) img"
    }

    override class var initialSourceBody: String {
        return "\(Settings.spacingValue)return sample(img, destCoord());"
    }

    override class func compile(source: String) -> Kernel? {
        if let kernel = CIColorKernel(source: source) {
            let result = CoreImageColorKernel()
            result.colorKernel = kernel
            return result
        }
        return nil
    }

    override func apply(with _: [CIImage], attributes: [Any]) -> CIImage? {
        guard let image = attributes.first as? CISampler else {
            return nil
        }
        return colorKernel?.apply(extent: image.extent, arguments: attributes)
    }
}
