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
