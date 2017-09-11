//
//  CIFilterHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 11.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import CoreImage

extension KernelType {
    
    fileprivate var swiftType: String {
        switch self {
        case .blend:
            return "\(CIBlendKernel.self)"
        case .color:
            return "\(CIColorKernel.self)"
        case .normal:
            return "\(CIKernel.self)"
        case .warp:
            return "\(CIWarpKernel.self)"
        }
    }
    
    fileprivate func swiftOutputImage(with arguments: [String]) -> String {
        switch self {
        case .warp:
            let guardArguments = ["input"].appending(with: arguments)
                .map{ "let \($0) = \($0)" }.joined(separator: ",\n\t\t\t")
            return """
            guard \(guardArguments) else {
                        return nil
                    }
                    return kernel?.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
                    return rect
                    }, image: input, arguments: [\(arguments.joined(separator: ","))] )
            """
        default:
            return ""
        }
    }
    
}

extension KernelAttributeType {
    
    var swiftType: String {
        switch self {
        case .color:
            return "\(CIColor.self)"
        case .float:
            return "\(Float.self)"
        case .sample:
            return "\(CISampler.self)"
        case .vec2,
             .vec3,
             .vec4:
            return "\(CIVector.self)"
        }
    }
    
}

class CIFilterHelper {

    class func cifilter(with kernelSource: String, type: KernelType, arguments: [KernelAttribute], name: String) -> String {
        let properties = arguments.map{ "\tvar \($0.name): \($0.type.swiftType)?" }.joined(separator: "\n")
        
        return """
import CoreImage

class \(name): CIFilter {
    
    // todo rename after the swift playgrounds bug got fixed
    var input: CIImage?
\(properties)
        
    var kernel: \(type.swiftType)? = {
        return \(type.swiftType)(source:\"\"\"
        \(kernelSource)\"\"\")
    }()
        
    override var outputImage: CIImage? {
        \(type.swiftOutputImage(with: arguments.map{ $0.name }))
    }

}
"""
    }
    
}
