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
