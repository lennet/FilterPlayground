//
//  ShadingLanguage.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum ShadingLanguage {
    case coreimage
    case metal
}

extension ShadingLanguage {
    var documentationURL: URL {
        switch self {
        case .coreimage:
            return URL(string: "https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CIKernelLangRef/ci_gslang_ext.html")!
        case .metal:
            // TODO:
            return URL(string: "https://developer.apple.com/")!
        }
    }

    var fileExtension: String {
        switch self {
        case .coreimage:
            return "cikernel"
        case .metal:
            return "metal"
        }
    }
}
