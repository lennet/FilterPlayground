//
//  KernelDescriptor.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

enum KernelType: String, Codable {
    case warp
    case color
}

extension KernelType {
    
    var returnType: KernelAttributeType {
        switch self {
        case .warp:
            return .vec2
        case .color:
            return .vec4
        }
    }
    
}

enum KernelAttributeType: String, Codable {
    
    case float
    case vec2
    case vec3
    case vec4
    case sampler
    
    static var all: [KernelAttributeType] {
        return [.float, .vec2, .vec3, .vec4, .sampler]
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
        // todo
        value = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }
    
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
