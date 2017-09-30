//
//  Kernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

protocol Kernel: class {

    var shadingLanguage: ShadingLanguage { get }
    
    static func compile(source: String) -> Kernel?

    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage?
}
