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
    var arguments: [(String, KernelArgumentType)]
}
