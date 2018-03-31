//
//  CoreImageBlendKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageBlendKernel: CoreImageKernel {
    override var type: KernelType {
        return .coreimageblend
    }

    override var extentSettings: KernelOutputSizeSetting {
        return .none
    }

    var blendKernel: CIBlendKernel?

    override class var supportedArguments: [KernelArgumentType] {
        return []
    }

    override class var initialArguments: String {
        return "\(KernelArgumentType.sample.rawValue) fore, \(KernelArgumentType.sample.rawValue) back"
    }

    override var requiredInputImages: Int {
        return 2
    }

    override class var initialSourceBody: String {
        return "\(Settings.spacingValue)return sample(fore, destCoord()) + sample(back, destCoord());"
    }

    override func compile(source: String) -> Bool {
        if let kernel = CIBlendKernel(source: source) {
            blendKernel = kernel
            return true
        }
        return false
    }

    override func apply(with inputImages: [CIImage], attributes _: [KernelArgumentValue]) -> CIImage? {
        guard let first = inputImages.first,
            let second = inputImages.last,
            inputImages.count == 2 else {
            return nil
        }

        return blendKernel?.apply(foreground: first, background: second) }
}
