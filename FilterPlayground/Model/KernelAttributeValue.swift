//
//  KernelAttributeValue.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

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
        case .sample:
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
