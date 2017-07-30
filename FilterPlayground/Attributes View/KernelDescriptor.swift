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

extension KernelType {
    var returnType: String {
        switch self {
        case .warp:
            return "vec 2"
        case .color:
            return "vec 4"
        }
    }
}

enum KernelAttributeType {
    
    case float
    case image
    
    static var all: [KernelAttributeType] {
        return [.float, .image]
    }
    
}

struct KernelAttribute {
    var name: String
    var type: KernelAttributeType?
    var value: Any?
}

struct KernelDescriptor {
    var name: String
    var type: KernelType
    var attributes: [KernelAttribute]
}

extension KernelDescriptor {
    
    var prefix: String {
        let parameter = attributes
            .filter{ $0.type != nil }
            .map{ "\($0.type!) \($0.name)" }
            .joined(separator: ", ")
        return "kernel \(type.returnType) \(name)(\(parameter)) {\n"
    }
    
}
