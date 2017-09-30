//
//  KernelType.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelType: String, Codable {
    case coreimage
    case coreimagewarp
    case coreimagecolor
    case coreimageblend
    case metal
    
    var kernelClass: Kernel.Type {
        switch self {
        case .coreimage:
            return CoreImageKernel.self
        case .coreimagewarp:
            return CoreImageWarpKernel.self
        case .coreimagecolor:
            return CoreImageColorKernel.self
        case .coreimageblend:
            return CoreImageBlendKernel.self
        case .metal:
            return MetalKernel.self
        }
    }
}

extension KernelType {
    
    var returnType: KernelAttributeType {
        switch self {
        case .coreimage,
             .coreimagecolor,
             .coreimageblend:
            return .vec4
        default:
            return .vec2
        }
    }
    
    var requiredArguments: [KernelAttributeType] {
        switch self {
        case .coreimagecolor:
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
        case .coreimagecolor:
            return "\(KernelAttributeType.sample.rawValue) img"
        case .coreimageblend:
            return "\(KernelAttributeType.sample.rawValue) fore, \(KernelAttributeType.sample.rawValue) back"
        default:
            return ""
        }
    }
    
    var initialSourceBody: String {
        switch self {
        case .coreimagecolor:
            return "\(Settings.spacingValue)return sample(img, destCoord());"
        case .coreimagewarp:
            return "\(Settings.spacingValue)return destCoord();"
        case .coreimageblend:
            return "\(Settings.spacingValue)return sample(fore, destCoord()) + sample(back, destCoord());"
        case .coreimage:
            return "\(Settings.spacingValue)return vec4(1.0, 1.0, 1.0, 1.0);"
        case .metal:
            return ""
        }
    }
    
    var requiredInputImages: Int {
        switch self {
        case .coreimageblend:
            return 2
        case .coreimagewarp:
            return 1
        default:
            return 0
        }
    }
    
    var supportsAttributes: Bool {
        switch self {
        case .coreimageblend:
            return false
        default:
            return true
        }
    }
    
    var compile: (String) -> KernelCompilerResult {
        return { source in
            return self.kernelClass.compile(source: source)
        }
    }
}
