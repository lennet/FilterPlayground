//
//  ProjectMetaData.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import UIKit

struct ProjectMetaData {

    var arguments: [KernelArgument]
    var inputImages: [KernelInputImage]
    var type: KernelType
    var name: String

    init(arguments: [KernelArgument], type: KernelType, inputImages: [KernelInputImage]) {
        self.arguments = arguments
        self.type = type
        name = "untitled"
        self.inputImages = inputImages
    }

    func initialSource() -> String {
        return type.kernelClass.initialSource(with: name)
    }

    func initalArguments() -> [KernelArgument] {
        if let kernelType = type.kernelClass as? CoreImageKernel.Type {
            return kernelType.requiredArguments.map { KernelArgument(name: "unamed", type: $0, value: $0.defaultValue) }
        }
        // TODO:
        return []
    }

    func initialInputImages() -> [KernelInputImage] {
        return (0 ..< type.kernelClass.requiredInputImages).map { KernelInputImage(image: nil, index: $0, shouldHighlightIfMissing: false) }
    }
}

extension ProjectMetaData: Codable {

    enum CodingKeys: String, CodingKey {
        case arguments
        case name
        case type
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(KernelType.self, forKey: .type)
        arguments = try values.decode([KernelArgument].self, forKey: .arguments)
        inputImages = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(arguments, forKey: .arguments)
    }
}
