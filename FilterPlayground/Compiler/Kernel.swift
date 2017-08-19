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
        let result = GeneralKernel()
        result.kernel = CIKernel(source: source)
        return result
    }
    
    func apply(with inputImages: [UIImage], attributes: [Any]) -> UIImage? {
        let arguments: [Any] = attributes
            guard let result = kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000) ), roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: arguments) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
    
}

class BlendKernel: Kernel {
    var kernel: CIBlendKernel?
    
    static func compile(source: String) -> Kernel? {
        let result = BlendKernel()
        result.kernel = CIBlendKernel(source: source)
        return result
    }
    
    func apply(with inputImages: [UIImage], attributes: [Any]) -> UIImage? {
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
