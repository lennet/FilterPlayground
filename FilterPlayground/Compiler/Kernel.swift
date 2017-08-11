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
    
    func apply(to image: UIImage, attributes: [Any]) -> UIImage?
}

class GeneralKernel: Kernel {
    var kernel: CIKernel?
    
    static func compile(source: String) -> Kernel? {
        let result = GeneralKernel()
        result.kernel = CIKernel(source: source)
        return result
    }
    
    func apply(to image: UIImage, attributes: [Any]) -> UIImage? {
        let arguments: [Any] = attributes
        // todo
//        if let input = CIImage(image: image)  {
//            arguments =  [input] + attributes
//        } else {
//            arguments =
//        }
        
        guard let result = kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 900, height: 200) ), roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: arguments) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
    
}
