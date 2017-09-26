//
//  CIKernelLanguageHelper.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 25.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class CIKernelLanguageHelper {
    
    static var functions: [String] = {
        // todo add
        return  KernelAttributeType.all.map{ $0.rawValue } + ["mod", "destCoord()"]
    }()
    
}
