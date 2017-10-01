//
//  Kernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

protocol Kernel: class {

    static var shadingLanguage: ShadingLanguage { get }

    static var supportedArguments: [KernelArgumentType] { get }

    static func initialSource(with name: String) -> String

    static var requiredInputImages: Int { get }

    static func compile(source: String) -> KernelCompilerResult

    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage?
}

extension Kernel {

    static var supportsArguments: Bool {
        return supportedArguments.count > 0
    }
}
