//
//  DataBinding.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum DataBinding: String, Codable {
    case none
    case time
    case camera
    case touch
}

extension DataBinding {
    var emitter: DataBindingEmitter.Type? {
        switch self {
        case .time:
            return TimeDataBindingEmitter.self
        case .camera:
            return CameraDataBindingEmitter.self
        case .touch:
            return TouchDataBindingEmitter.self
        case .none:
            return nil
        }
    }
}
