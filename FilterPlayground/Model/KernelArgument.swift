
//
//  KernelArgument.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

struct KernelArgument {
    var index: Int
    var name: String
    var type: KernelArgumentType
    var value: KernelArgumentValue
    var binding: DataBinding?
    var access: KernelArgumentAccess
    var origin: KernelArgumentOrigin
}

extension KernelArgument {
    init(index: Int, name: String, type: KernelArgumentType, value: KernelArgumentValue, access: KernelArgumentAccess = .na, origin: KernelArgumentOrigin = .na) {
        self.init(index: index, name: name, type: type, value: value, binding: nil, access: access, origin: origin)
    }
}

extension KernelArgument: Codable {
    enum CodingKeys: String, CodingKey {
        case index
        case name
        case type
        case value
        case binding
        case access
        case origin
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = try values.decode(Int.self, forKey: .index)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(KernelArgumentType.self, forKey: .type)
        binding = try? values.decode(DataBinding.self, forKey: .binding)
        access = try values.decode(KernelArgumentAccess.self, forKey: .access)
        origin = try values.decode(KernelArgumentOrigin.self, forKey: .origin)

        if type == .sample {
            // this value gets overriden in the load method
            value = KernelArgumentValue.sample(CIImage(color: .black))
        } else {
            value = try values.decode(KernelArgumentValue.self, forKey: .value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(binding, forKey: .binding)
        try container.encode(access, forKey: .access)
        try container.encode(origin, forKey: .origin)
        if type != .sample {
            // we are not encoding images in the json
            try container.encode(value, forKey: .value)
        } else {
            try container.encode("", forKey: .value)
        }
    }
}
