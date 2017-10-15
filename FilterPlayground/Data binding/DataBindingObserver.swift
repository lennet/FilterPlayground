//
//  DataBindingObserver.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

protocol DataBindingObserver {
    var observedBinding: DataBinding { get }
    // todo make type safe
    func valueChanged(value: Any)
}
