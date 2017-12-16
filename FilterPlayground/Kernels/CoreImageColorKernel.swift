//
//  CoreImageColorKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageColorKernel: CoreImageKernel {

    override var extent: CGRect {
        switch outputSize {
        case .inherit:
            guard let image = arguments.first?.value.asKernelValue as? CISampler else {
                return CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000))
            }
            return image.extent
        case let .custom(value):
            return value
        }
    }

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

    override func compile(source: String) -> Bool {
        if let kernel = CIColorKernel(source: source) {
            colorKernel = kernel
            return true
        }
        return false
    }

    override func apply(with _: [CIImage], attributes: [KernelArgumentValue]) -> CIImage? {
        let arguments = attributes.flatMap { $0.asKernelValue }
        return colorKernel?.apply(extent: extent, arguments: arguments)
    }
}
