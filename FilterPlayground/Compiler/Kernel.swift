//
//  Kernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol Kernel: class {

    static func compile(source: String) -> Kernel?

    func apply(with inputImages: [UIImage], attributes: [Any]) -> UIImage?
}

class GeneralKernel: Kernel {
    var kernel: CIKernel?

    static func compile(source: String) -> Kernel? {
        if let kernel = CIKernel(source: source) {
            let result = GeneralKernel()
            result.kernel = kernel
            return result
        }
        return nil
    }

    func apply(with _: [UIImage], attributes: [Any]) -> UIImage? {
        let arguments: [Any] = attributes
        guard let result = kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), roiCallback: { (_, rect) -> CGRect in
            rect
        }, arguments: arguments) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
}

class BlendKernel: Kernel {
    var kernel: CIBlendKernel?

    static func compile(source: String) -> Kernel? {
        if let kernel = CIBlendKernel(source: source) {
            let result = BlendKernel()
            result.kernel = kernel
            return result
        }
        return nil
    }

    func apply(with inputImages: [UIImage], attributes _: [Any]) -> UIImage? {
        guard let first = inputImages.first?.asCIImage,
            let second = inputImages.last?.asCIImage,
            inputImages.count == 2 else {
            return nil
        }

        guard let result = kernel?.apply(foreground: first, background: second) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
}
