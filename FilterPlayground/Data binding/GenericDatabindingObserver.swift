//
//  GenericDatabindingObserver.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import CoreImage

class GenericDatabindingObserver: DataBindingObserver {

    var argument: KernelArgument
    var didUpdateArgument: ((KernelArgument) -> Void)?

    init(argument: KernelArgument) {
        self.argument = argument
        DataBindingContext.shared.add(observer: self, with: argument.name)
    }

    var observedBinding: DataBinding {
        return argument.binding ?? .none
    }

    func valueChanged(value: Any) {
        var newValue: KernelArgumentValue?
        switch (argument.type, observedBinding) {
        case (.float, .time):
            if let time = value as? TimeInterval {
                newValue = .float(Float(time))
            }
            break
        case (.sample, .camera):
            if let image = value as? CIImage {
                newValue = .sample(image)
            }
            break
        case (.vec2, .touch):
            if let point = value as? CGPoint {
                newValue = .vec2(Float(point.x), Float(point.y))
            }
            break
        default:
            break
        }
        if let newValue = newValue {
            argument.value = newValue
            didUpdateArgument?(argument)
        }
    }
}
