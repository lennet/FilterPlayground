//
//  KernelAttributeType.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage
#if os(iOS) || os(tvOS)
    import UIKit
#endif

enum KernelArgumentType: String, Codable {

    case float
    case vec2
    case vec3
    case vec4
    case sample = "__sample"
    case color = "__color"

    static var all: [KernelArgumentType] {
        return [.float, .vec2, .vec3, .vec4, .sample, .color]
    }
}

extension KernelArgumentType {

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
