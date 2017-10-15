//
//  ProjectMetaData.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import UIKit

struct ProjectMetaData: Codable {

    var attributes: [KernelArgument]
    var type: KernelType
    var name: String

    init(attributes: [KernelArgument], type: KernelType) {
        self.attributes = attributes
        self.type = type
        name = "untitled"
    }

    func initialSource() -> String {
        return type.kernelClass.initialSource(with: name)
    }

    func initalArguments() -> [KernelArgument] {
        if let kernelType = type.kernelClass as? CoreImageKernel.Type {
            return kernelType.requiredArguments.map { KernelArgument(name: "unamed", type: $0, value: $0.defaultValue) }
        }
        // todo
        return []
    }

    func initialInputImages() -> [UIImage] {
        // TODO:
        return []
    }
}
