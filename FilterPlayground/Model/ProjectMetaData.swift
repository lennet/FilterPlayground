//
//  ProjectMetaData.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct ProjectMetaData: Codable {
    
    var attributes: [String: KernelAttribute]
    var type: KernelType
    var name: String
    
    init(attributes: [String: KernelAttribute], type: KernelType) {
        self.attributes = attributes
        self.type = type
        self.name = "untitled"
    }
    
    func initialSource() -> String {
        let parameter = ""
        return "kernel \(type.returnType) \(name)(\(parameter)) {\n\n}"
    }
}
