//
//  KernelDescriptor.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

#if os(iOS) || os(tvOS)
    import UIKit
#endif

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
             .color,
             .blend:
            return .vec4
        case .warp:
            return .vec2
        }
    }

    var requiredArguments: [KernelAttributeType] {
        switch self {
        case .color:
            return [.sample]
        default:
            return []
        }
    }

    func initialSource(with name: String) -> String {
        return "kernel \(returnType) \(name)(\(initialArguments)) {\n\(initialSourceBody)\n}"
    }

    var initialArguments: String {
        switch self {
        case .color:
            return "\(KernelAttributeType.sample.rawValue) img"
        case .blend:
            return "\(KernelAttributeType.sample.rawValue) fore, \(KernelAttributeType.sample.rawValue) back"
        default:
            return ""
        }
    }

    var initialSourceBody: String {
        switch self {
        case .color:
            return "\(Settings.spacingValue)return sample(img, destCoord());"
        case .warp:
            return "\(Settings.spacingValue)return destCoord();"
        case .blend:
            return "\(Settings.spacingValue)return sample(fore, destCoord()) + sample(back, destCoord());"
        case .normal:
            return "\(Settings.spacingValue)return vec4(1.0, 1.0, 1.0, 1.0);"
        }
    }

    var requiredInputImages: Int {
        switch self {
        case .blend:
            return 2
        case .warp:
            return 1
        default:
            return 0
        }
    }

    var supportsAttributes: Bool {
        switch self {
        case .blend:
            return false
        default:
            return true
        }
    }

    var compile: (String) -> KernelCompilerResult {
        switch self {
        case .color:
            return KernelCompiler<CIColorKernel>.compile
        case .warp:
            return KernelCompiler<CIWarpKernel>.compile
        case .normal:
            return KernelCompiler<GeneralKernel>.compile
        case .blend:
            return KernelCompiler<BlendKernel>.compile
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
    case sample(CIImage)
    case color(Float, Float, Float, Float)

    var asKernelValue: Any {
        switch self {
        case let .float(value):
            return value
        case let .vec2(a, b):
            return CIVector(x: CGFloat(a), y: CGFloat(b))
        case let .vec3(a, b, c):
            return CIVector(x: CGFloat(a), y: CGFloat(b), z: CGFloat(c))
        case let .vec4(a, b, c, d):
            return CIVector(x: CGFloat(a), y: CGFloat(b), z: CGFloat(c), w: CGFloat(d))
        case let .color(a, b, c, d):
            return CIColor(red: CGFloat(a), green: CGFloat(b), blue: CGFloat(c), alpha: CGFloat(d))
        case let .sample(image):
            return CISampler(image: image)
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
        case let .float(value):
            try container.encode(value, forKey: .float)
            break
        case let .vec2(a, b):
            try container.encode([a, b], forKey: .vec2)
            break
        case let .vec3(a, b, c):
            try container.encode([a, b, c], forKey: .vec3)
            break
        case let .vec4(a, b, c, d):
            try container.encode([a, b, c, d], forKey: .vec4)
            break
        case let .color(a, b, c, d):
            try container.encode([a, b, c, d], forKey: .color)
            break
        case .sample(_):
            // we are not encoding images in the json
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
            self = .color(value[0], value[1], value[2], value[3])
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
        if type == .sample {
            // this value gets overriden in the load method
            value = KernelAttributeValue.sample(CIImage(color: .black))
        } else {
            value = try values.decode(KernelAttributeValue.self, forKey: .value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        if type != .sample {
            // we are not encoding images in the json
            try container.encode(value, forKey: .value)
        } else {
            try container.encode("", forKey: .value)
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
            #if os(iOS) || os(tvOS)
                return .sample(#imageLiteral(resourceName: "DefaultImage").asCIImage!)
            #else
                return .sample(CIImage(color: .black))
            #endif
        }
    }
}
