
//
//  KernelArgument.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

struct KernelArgument {
    var name: String
    var type: KernelArgumentType
    var value: KernelArgumentValue
    var binding: DataBinding?
    var access: KernelArgumentAccess
}

extension KernelArgument {

    init(name: String, type: KernelArgumentType, value: KernelArgumentValue, access: KernelArgumentAccess = .na) {
        self.init(name: name, type: type, value: value, binding: nil, access: access)
    }
}

extension KernelArgument: Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case value
        case binding
        case access
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(KernelArgumentType.self, forKey: .type)
        binding = try? values.decode(DataBinding.self, forKey: .binding)
        access = try values.decode(KernelArgumentAccess.self, forKey: .access)

        if type == .sample {
            // this value gets overriden in the load method
            value = KernelArgumentValue.sample(CIImage(color: .black))
        } else {
            value = try values.decode(KernelArgumentValue.self, forKey: .value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(binding, forKey: .binding)
        try container.encode(access, forKey: .access)
        if type != .sample {
            // we are not encoding images in the json
            try container.encode(value, forKey: .value)
        } else {
            try container.encode("", forKey: .value)
        }
    }
}
