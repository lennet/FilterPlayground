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
    
    var compile: (String) -> KernelCompilerResult {
        switch self {
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

enum KernelAttributeValue {
    case float(Float)
    case vec2(Float, Float)
    case vec3(Float, Float, Float)
    case vec4(Float, Float, Float, Float)
    case sample(UIImage)
    case color(Float, Float, Float, Float)
    
    
    var asKernelValue: Any {
        switch self {
        case .float(let value):
            return value
        case .vec2(let a, let b):
            return CIVector(x: CGFloat(a), y: CGFloat(b))
        case .vec3(let a, let b, let c):
            return CIVector(x: CGFloat(a), y: CGFloat(b), z: CGFloat(c))
        case .vec4(let a, let b, let c, let d):
            return CIVector(x: CGFloat(a), y: CGFloat(b), z: CGFloat(c), w: CGFloat(d))
        case .color(let a, let b, let c, let d):
            return CIColor(red: CGFloat(a), green: CGFloat(b), blue: CGFloat(c), alpha: CGFloat(d))
        case .sample(let image):
            return CISampler(image: image.ciImage!)
        }
    }
}

extension KernelAttributeValue: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case float
        case vec2
        case vec3
        case vec4
        case sample
        case color
    }
    
    private enum CodableErrors: Error {
        case unkownValue
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .float(let value):
            try container.encode(value, forKey: .float)
            break
        case .vec2(let a, let b):
            try container.encode([a, b], forKey: .vec2)
            break
        case .vec3(let a, let b, let c):
            try container.encode([a, b, c], forKey: .vec3)
            break
        case .vec4(let a, let b, let c, let d):
            try container.encode([a, b, c, d], forKey: .vec4)
            break
        case .color(let a, let b, let c, let d):
            try container.encode([a, b, c, d], forKey: .vec4)
            break
        case .sample(let image):
            try container.encode(NSKeyedArchiver.archivedData(withRootObject: image), forKey: .sample)
            break
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Float.self, forKey: .float) {
            self = .float(value)
            return
        }
        if let value = try? values.decode([Float].self, forKey: .vec2) {
            guard value.count == 2 else {
                throw CodableErrors.unkownValue
            }
            self = .vec2(value[0], value[1])
            return
        }
        if let value = try? values.decode([Float].self, forKey: .vec3) {
            guard value.count == 3 else {
                throw CodableErrors.unkownValue
            }
            self = .vec3(value[0], value[1], value[2])
            return
        }
        if let value = try? values.decode([Float].self, forKey: .vec3) {
            guard value.count == 3 else {
                throw CodableErrors.unkownValue
            }
            self = .vec3(value[0], value[1], value[2])
            return
        }
        if let value = try? values.decode([Float].self, forKey: .vec4) {
            guard value.count == 4 else {
                throw CodableErrors.unkownValue
            }
            self = .vec4(value[0], value[1], value[2], value[3])
            return
        }
        if let value = try? values.decode([Float].self, forKey: .color) {
            guard value.count == 4 else {
                throw CodableErrors.unkownValue
            }
            self = .vec4(value[0], value[1], value[2], value[3])
            return
        }
        if let value = try? values.decode(Data.self, forKey: .sample) {
            guard let image = NSKeyedUnarchiver.unarchiveObject(with: value) as? UIImage else {
                throw CodableErrors.unkownValue
            }
            self = .sample(image)
            return
        }
        throw CodableErrors.unkownValue
    }

}

struct KernelAttribute {
    var name: String
    var type: KernelAttributeType
    var value: KernelAttributeValue
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
        value = try values.decode(KernelAttributeValue.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        switch type {
        case .float:
            try container.encode(value, forKey: .value)
            break
        default:
            break
        }
    }
    
}

extension KernelAttributeType {
    
    var defaultValue: KernelAttributeValue {
        switch self {
        case .float:
            return .float(0)
        case .vec2:
            return .vec2(0, 0)
        case .vec3:
            return .vec3(0, 0, 0)
        case .vec4:
            return .vec4(0, 0, 0, 0)
        case .color:
            return .color(0, 0, 0, 0)
        case .sample:
            return .sample(UIImage())
        }
    }
    
}
