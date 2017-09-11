//
//  SwiftPlaygroundsHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 11.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import UIKit

extension KernelAttributeValue {
    
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
        }
    }
    
}

class SwiftPlaygroundsHelper {

    static var xcplaygroundData: Data = {
        let content = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<playground version='5.0' target-platform='ios'>
    <timeline fileName='timeline.xctimeline'/>
</playground>
"""
        return content.data(using: .utf8)!
    }()
    
    class func swiftPlayground(with document: Document) -> URL {
        let filterName = document.localizedName.withoutWhiteSpaces.withoutSlash
        let definedVariables = document.metaData.attributes.map{ "var \($0.name): \($0.type.swiftType) = \($0.value.swiftPlaygroundValue(with:  $0.name))" }.joined(separator: "\n")
        let assignFilterProperties = document.metaData.attributes.map{ "filter.\($0.name) = \($0.name)" }.joined(separator: "\n")
        
        var inputImageAssignment = ""
        if document.metaData.type.requiredInputImages > 0 {
            inputImageAssignment = "let image = #imageLiteral(resourceName: \"input.png\")\nfilter.input = CIImage(image: image)"
        }
        let content = """
        import UIKit
        \(CIFilterHelper.cifilter(with: document.source, type: document.metaData.type, arguments: document.metaData.attributes, name: filterName))
        
        \(definedVariables)
        
        let filter = \(filterName)()
        \(inputImageAssignment)
        \(assignFilterProperties)
        
        let result = filter.outputImage
        """
        return SwiftPlaygroundsHelper.swiftPlayground(with: content, resources: swiftPlaygroundResourcesFolder(with: document))
    }
    
    class func swiftPlaygroundResourcesFolder(with document: Document) -> FileWrapper {
        
        var resources: [(String, Data)] = document.metaData.attributes
            .flatMap{ guard case .sample(let image) = $0.value  else {return nil}
                return ($0.name, UIImagePNGRepresentation(image)!) }
        
        if let input = document.inputImages.first {
            resources.append(("input", UIImagePNGRepresentation(input)!))
        }
        
        var resourceWrappers: [String: FileWrapper] = [:]
        for resource in resources {
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
