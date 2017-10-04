//
//  Kernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage
#if os(iOS) || os(tvOS)
    import UIKit
    typealias KernelOutputView = UIView
#else
    import AppKit
    typealias KernelOutputView = NSView
#endif

protocol Kernel: class {

    static var shadingLanguage: ShadingLanguage { get }

    static var supportedArguments: [KernelArgumentType] { get }

    static func initialSource(with name: String) -> String

    static var requiredInputImages: Int { get }

    func compile(source: String, completion: @escaping (KernelCompilerResult) -> Void)

    func apply(with inputImages: [CIImage], attributes: [Any]) -> CIImage?

    func render(with inputImages: [CIImage], attributes: [Any])

    var outputView: KernelOutputView { get }

    init()
}

extension Kernel {

    static var supportsArguments: Bool {
        return supportedArguments.count > 0
    }
}
