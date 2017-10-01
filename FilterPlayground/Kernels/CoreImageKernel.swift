//
//  CoreImageKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage

class CoreImageKernel: Kernel {

    required init() {}

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

    func compile(source: String) -> KernelCompilerResult {
        let errorHelper = ErrorHelper()
        if compile(source: source) {
            return KernelCompilerResult.success(errors: [])
        } else if let errorString = errorHelper.errorString() {
            return .failed(errors: CoreImageErrorParser.compileErrors(for: errorString))
        }
        return .failed(errors: [KernelError.compile(lineNumber: -1, characterIndex: -1, type: .error, message: "Unkown Error. Please check your code.", note: nil)])
    }

    func compile(source: String) -> Bool {
        if let kernel = CIKernel(source: source) {
            self.kernel = kernel
            return true
        }
        return false
    }

    func apply(with _: [CIImage], attributes: [Any]) -> CIImage? {
        let arguments: [Any] = attributes
        return kernel?.apply(extent: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), roiCallback: { (_, rect) -> CGRect in
            rect
        }, arguments: arguments)
    }
}
