//
//  CIKernelLanguageHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 25.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class CIKernelLanguageHelper {
    
    static var functions: [String] = {
        // todo add
        return ["(", ")", ".", ",", "if", "for", "/", "*" , "-"] + KernelAttributeType.all.map{ $0.rawValue} + ["mod",
                                                                                                                "compare",
                                                                                                                "cos_",
                                                                                                                "cossin",
                                                                                                                "cossin_",
                                                                                                                "destCoord",
                                                                                                                "premultiply",
                                                                                                                "sample",
                                                                                                                "samplerCoord",
                                                                                                                "samplerExtent",
                                                                                                                "samplerOrigin",
                                                                                                                "samplerSize",
                                                                                                                "samplerTransform",
                                                                                                                "sin_",
                                                                                                                "sincos",
                                                                                                                "sincos_",
                                                                                                                "tan_",
                                                                                                                "unpremultiply"]
    }()
    
    
}
