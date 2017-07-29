//
//  KernelDescriptor.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum KernelType {
    case warp
    case color
}

enum KernelAttribute {
    case float(value: Float)
    case image(image: UIImage)
    case unkwon(identifier: String?, value: String?)
    case none
}

struct KernelDescriptor {
    
    var name: String
    var type: KernelType
    var attributes: [KernelAttribute]
    
}
