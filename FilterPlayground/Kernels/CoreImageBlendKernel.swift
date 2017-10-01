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

    override class var supportedArguments: [KernelArgumentType] {
        return []
    }

    override class var initialArguments: String {
        return "\(KernelArgumentType.sample.rawValue) fore, \(KernelArgumentType.sample.rawValue) back"
    }

    override class var requiredInputImages: Int {
        return 2
    }

    override class var initialSourceBody: String {
        return "\(Settings.spacingValue)return sample(fore, destCoord()) + sample(back, destCoord());"
    }

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
