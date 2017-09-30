
//
//  KernelAttribute.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

struct KernelAttribute {
    var name: String
    var type: KernelAttributeType
    var value: KernelAttributeValue
}

extension KernelAttribute: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(KernelAttributeType.self, forKey: .type)
        if type == .sample {
            // this value gets overriden in the load method
            value = KernelAttributeValue.sample(CIImage(color: .black))
        } else {
            value = try values.decode(KernelAttributeValue.self, forKey: .value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        if type != .sample {
            // we are not encoding images in the json
            try container.encode(value, forKey: .value)
        } else {
            try container.encode("", forKey: .value)
        }
    }
    
}
