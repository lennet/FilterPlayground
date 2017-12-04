//
//  DataBindingEmitter.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

protocol DataBindingEmitter {
    func activate()
    func deactivate()
    
    var isActive: Bool { get }

    static var shared: DataBindingEmitter { get }
}
