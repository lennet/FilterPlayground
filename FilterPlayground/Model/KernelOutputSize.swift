//
//  KernelOutputSize.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreGraphics

enum KernelOutputSize {
    case inherit
    case custom(CGRect)
}

extension KernelOutputSize: Codable {
    private enum CodableErrors: Error {
        case unkownValue
    }

    private enum CodingKeys: String, CodingKey {
        case inherit
        case custom
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .custom(value):
            try container.encode(value, forKey: .custom)
        case .inherit:
            try container.encode(true, forKey: .inherit)
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(CGRect.self, forKey: .custom) {
            self = .custom(value)
        } else if let value = try? values.decode(Bool.self, forKey: .inherit),
            value == true {
            self = .inherit
        }
        throw CodableErrors.unkownValue
    }
}
