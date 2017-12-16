//
//  SwiftPlaygroundsHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 11.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

extension KernelArgumentValue {
    
    fileprivate func swiftPlaygroundValue(with attributeName: String) -> String {
        switch self {
        case .color(let r, let g, let b, let a):
            return "CIColor(red: \(r), green: \(g), blue: \(b), alpha: \(a))"
        case .float(let f):
            return "\(f)"
        case .sample(_):
            return "CISampler(image: CIImage(image: #imageLiteral(resourceName: \"\(attributeName).png\"))!)"
        case .vec2(let a, let b):
            return "CIVector(x: \(a), y: \(b))"
        case .vec3(let a, let b, let c):
            return "CIVector(x: \(a), y: \(b), z: \(c))"
        case .vec4(let a, let b, let c, let d):
            return "CIVector(x: \(a), y: \(b), z: \(c), w: \(d))"
        case .uint2:
            fatalError()
        }
    }
    
}

class SwiftPlaygroundsExportHelper {

    static var xcplaygroundData: Data = {
        let content = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<playground version='5.0' target-platform='ios'>
    <timeline fileName='timeline.xctimeline'/>
</playground>
"""
        return content.data(using: .utf8)!
    }()
    
    class func swiftPlayground(with name: String, type: KernelType, kernelSource: String, arguments: [KernelArgument] ,inputImages: [Data]) -> URL {
        
        let definedVariables = arguments.map{ "var \($0.name): \($0.type.swiftType) = \($0.value.swiftPlaygroundValue(with:  $0.name))" }.joined(separator: "\n")
        let assignFilterProperties = arguments.map{ "filter.\($0.name) = \($0.name)" }.joined(separator: "\n")
        
        var inputImageAssignment = ""
        if inputImages.count == 1 {
            inputImageAssignment = "let image = #imageLiteral(resourceName: \"input.png\")\nfilter.input = CIImage(image: image)"
        } else if inputImages.count == 2 {
            inputImageAssignment = """
            let fore = #imageLiteral(resourceName: \"fore.png\")
            filter.fore = CIImage(image: fore)
            
            let back = #imageLiteral(resourceName: \"back.png\")
            filter.back = CIImage(image: back)

            """
        }
        let content = """
        import UIKit
        \(CIFilterExportHelper.cifilter(with: kernelSource, type: type, arguments: arguments, name: name) as String)
        
        \(definedVariables)
        
        let filter = \(name)()
        \(inputImageAssignment)
        \(assignFilterProperties)
        
        let result = filter.outputImage
        """
        
        var resources: [(String, Data)] = arguments
            .flatMap{ guard case .sample(let image) = $0.value  else {return nil}
                return ($0.name, image.asJPGData!) }
        
        if inputImages.count == 1 {
            resources.append(("input", inputImages[0]))
        } else if inputImages.count == 2 {
            resources.append(contentsOf: [("fore", inputImages[0]),
                                          ("back", inputImages[1])])
        }
        
        return SwiftPlaygroundsExportHelper.swiftPlayground(with: content, resources: swiftPlaygroundResourcesFolder(with: resources))
    }
    
    class func swiftPlaygroundResourcesFolder(with files: [(String, Data)]) -> FileWrapper {
        
        var resourceWrappers: [String: FileWrapper] = [:]
        for resource in files {
            resourceWrappers["\(resource.0).png"] = FileWrapper(regularFileWithContents: resource.1)
        }

        return FileWrapper(directoryWithFileWrappers: resourceWrappers)
    }
    
    class func swiftPlayground(with contentSource: String, resources: FileWrapper? = nil) -> URL {
        let contentSourceData = contentSource.data(using: .utf8)!
        let contentsFileWrapper = FileWrapper(regularFileWithContents: contentSourceData)
        let xcplaygroundFileWrapper = FileWrapper(regularFileWithContents: xcplaygroundData)

        var fileWrappers = ["contents.xcplayground" : xcplaygroundFileWrapper,
                            "Contents.swift": contentsFileWrapper]
        if let resources = resources {
            fileWrappers["Resources"] = resources
        }
        let fileWrapper = FileWrapper(directoryWithFileWrappers: fileWrappers)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("test.playground")
        try? fileWrapper.write(to: url, options: .atomic, originalContentsURL: nil)
        return url
    }
    
}
