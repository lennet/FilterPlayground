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
        case .coreimageblend:
            return "\(CIBlendKernel.self)"
        case .coreimagecolor:
            return "\(CIColorKernel.self)"
        case .coreimage:
            return "\(CIKernel.self)"
        case .coreimagewarp:
            return "\(CIWarpKernel.self)"
        case .metal:
            return ""
        }
    }
    
    fileprivate func swiftOutputImage(with arguments: [String]) -> String {
        switch self {
        case .coreimagewarp:
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
        case .coreimagecolor:
            let guardArguments = arguments.map{ "let \($0) = \($0)" }.joined(separator: ",\n\t\t\t")
            return """
            guard \(guardArguments) else {
                    return nil
                    }
                    return kernel?.apply(extent: \(arguments[0]).extent, arguments: [\(arguments.joined(separator: ","))] )
            """
        case .coreimage:
            let guardArguments = arguments.map{ "let \($0) = \($0)" }.joined(separator: ",\n\t\t\t")
            var guardStatement = ""
            if !guardArguments.isEmpty {
                guardStatement = """
                guard \(guardArguments) else {
                return nil
                }
                """
            }
            return """
            \(guardStatement)
            return kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), roiCallback: { (_, rect) -> CGRect in
            rect
            }, arguments: [\(arguments.joined(separator: ","))])
            """
        case .coreimageblend:
            return """
                guard let fore = fore,
                    let back = back else {
                        return nil
                }
            
                return kernel?.apply(foreground: fore, background: back)
            """
        case .metal:
            return ""
        }
    }
    
}

extension KernelArgumentType {
    
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

    class func cifilter(with kernelSource: String, type: KernelType, arguments: [KernelAttribute], name: String) -> Data? {
        let source: String = CIFilterHelper.cifilter(with: kernelSource, type: type, arguments: arguments, name: name)
        return source.data(using: .utf8)
    }
    
    class func cifilter(with kernelSource: String, type: KernelType, arguments: [KernelAttribute], name: String) -> String {
        let properties = arguments.map{ "\tvar \($0.name): \($0.type.swiftType)?" }.joined(separator: "\n")
        var inputProperties = ""
        if type.kernelClass.requiredInputImages == 1 {
            inputProperties = "\tvar input: CIImage?"
        } else if type.kernelClass.requiredInputImages == 2 {
            inputProperties = """
            \tvar fore: CIImage?
            \tvar back: CIImage?
            """
        }
        return """
import CoreImage

class \(name): CIFilter {
    
    // todo rename after the swift playgrounds bug got fixed
\(inputProperties)
\(properties)
        
    var kernel: \(type.swiftType)? = {
        return \(type.swiftType)(source:\"\"\"
        \(kernelSource)
\"\"\")
    }()
        
    override var outputImage: CIImage? {
        \(type.swiftOutputImage(with: arguments.map{ $0.name }))
    }

}
"""
    }
    
}
