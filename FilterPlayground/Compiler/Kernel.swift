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
    var arguments: [KernelArgument] { get set }
    var inputImages: [CIImage] { get set }

    var extentSettings: KernelOutputSizeSetting { get }
    var outputSize: KernelOutputSize { get set }
    var extent: CGRect { get }

    static var supportedArguments: [KernelArgumentType] { get }

    static func initialSource(with name: String) -> String

    static var requiredInputImages: Int { get }

    func compile(source: String, completion: @escaping (KernelCompilerResult) -> Void)

    func getImage() -> CIImage?

    func render()

    var outputView: KernelOutputView { get }

    init()
}

extension Kernel {
    static var supportsArguments: Bool {
        return supportedArguments.count > 0
    }
}
