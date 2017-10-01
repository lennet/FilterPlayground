//
//  CoreImageKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageKernel: Kernel {

    class var requiredArguments: [KernelArgumentType] {
        return []
    }

    class var requiredInputImages: Int {
        return 0
    }

    class var supportedArguments: [KernelArgumentType] {
        return [.float, .vec2, .vec3, .vec4, .sample, .color]
    }

    class var shadingLanguage: ShadingLanguage {
        return .coreimage
    }

    static func initialSource(with name: String) -> String {
        return "kernel \(returnType) \(name)(\(initialArguments)) {\n\(initialSourceBody)\n}"
    }

    class var initialArguments: String {
        return ""
    }

    class var returnType: KernelArgumentType {
        return .vec4
    }

    class var initialSourceBody: String {
        return "\(Settings.spacingValue)return vec4(1.0, 1.0, 1.0, 1.0);"
    }

    var kernel: CIKernel?

    static func compile(source: String) -> KernelCompilerResult {
        let errorHelper = ErrorHelper()
        if let kernel: Kernel = compile(source: source) {
            return KernelCompilerResult.success(kernel: kernel, errors: [])
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: CoreImageErrorParser.compileErrors(for: errorString))
        }
        return .failed(errors: [KernelError.compile(lineNumber: -1, characterIndex: -1, type: .error, message: "Unkown Error. Please check your code.", note: nil)])
    }

    class func compile(source: String) -> Kernel? {
        if let kernel = CIKernel(source: source) {
            let result = CoreImageKernel()
            result.kernel = kernel
            return result
        }
        return nil
    }

    func apply(with _: [CIImage], attributes: [Any]) -> CIImage? {
        let arguments: [Any] = attributes
        return kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), roiCallback: { (_, rect) -> CGRect in
            rect
        }, arguments: arguments)
    }
}
