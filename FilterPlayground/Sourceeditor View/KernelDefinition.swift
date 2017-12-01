//
//  KernelDefinition.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct KernelDefinition {
    var name: String
    var returnType: KernelArgumentType
    var arguments: [KernelDefinitionArgument]
}

extension KernelDefinition: Equatable {
    static func == (lhs: KernelDefinition, rhs: KernelDefinition) -> Bool {
        return lhs.name == rhs.name &&
            lhs.returnType == rhs.returnType &&
            lhs.arguments == rhs.arguments
    }
}

struct KernelDefinitionArgument {

    var name: String
    var type: KernelArgumentType
    var access: KernelArgumentAccess

    init(name: String, type: KernelArgumentType, access: KernelArgumentAccess = .na) {
        self.name = name
        self.type = type
        self.access = access
    }
}

extension KernelDefinitionArgument: Equatable {
    static func == (lhs: KernelDefinitionArgument, rhs: KernelDefinitionArgument) -> Bool {
        return lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.access == rhs.access
    }
}

enum KernelArgumentAccess: String, Codable {
    case read
    case write
    case na
}
