//
//  KernelDescriptor.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum KernelType: String, Codable {
    case normal
    case warp
    case color
    case blend
}

extension KernelType {
    
    var returnType: KernelAttributeType {
        switch self {
        case .normal,
             .warp:
            return .vec2
        case .color,
             .blend:
            return .vec4
        }
    }
    
}

enum KernelAttributeType: String, Codable {
    
    case float
    case vec2
    case vec3
    case vec4
    case sample = "__sample"
    case color = "__color"
    
    static var all: [KernelAttributeType] {
        return [.float, .vec2, .vec3, .vec4, .sample, .color]
    }
    
}

struct KernelAttribute {
    var name: String
    var type: KernelAttributeType?
    var value: Any?
}

extension KernelAttribute: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(KernelAttributeType.self, forKey: .type)
        switch type {
        case .float?:
            value = try values.decode(Float.self, forKey: .value)
            break
        default:
            value = nil
            break
        }
        // todo
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        switch type {
        case .float?:
            try container.encode((value as? Float) ?? 0, forKey: .value)
            break
        default:
            break
        }
    }
    
}

struct KernelDescriptor {
    var name: String
    var type: KernelType
    var attributes: [KernelAttribute]
    
    var compile: (String) -> KernelCompilerResult {
        switch type {
        case .color:
            return KernelCompiler<CIColorKernel>.compile
        case .warp:
            return KernelCompiler<CIWarpKernel>.compile
        default:
            // todo!
            return KernelCompiler<CIWarpKernel>.compile
        }
    }
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
