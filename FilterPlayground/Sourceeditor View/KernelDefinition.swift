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
    var origin: KernelArgumentOrigin

    init(name: String, type: KernelArgumentType, access: KernelArgumentAccess = .na, origin: KernelArgumentOrigin = .na) {
        self.name = name
        self.type = type
        self.access = access
        self.origin = origin
    }
}

extension KernelDefinitionArgument: Equatable {
    static func == (lhs: KernelDefinitionArgument, rhs: KernelDefinitionArgument) -> Bool {
        return lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.access == rhs.access
    }
}

enum KernelArgumentOrigin: Codable {

    private enum CodingKeys: String, CodingKey {
        case buffer
        case other
        case texture
        case na
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .buffer:
            try container.encode(true, forKey: .buffer)
            break
        case let .other(value):
            try container.encode(value, forKey: .other)
            break
        case .texture:
            try container.encode(true, forKey: .texture)
            break
        case .na:
            try container.encode(true, forKey: .na)
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if values.contains(.buffer) {
            self = .buffer
            return
        }
        if values.contains(.na) {
            self = .na
            return
        }
        if values.contains(.texture) {
            self = .texture
            return
        }
        if let value = try? values.decode(String.self, forKey: .other) {
            self = .other(value)
            return
        }
        self = .na
    }

    case buffer
    case texture
    case other(String)
    case na
}

enum KernelArgumentAccess: String, Codable {
    case read
    case write
    case constant
    case na
}
