//
//  MockKernel.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 02.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import UIKit

class MockKernel: Kernel {
    required init() {
    }

    var arguments: [KernelArgument] = []

    var inputImages: [CIImage] {
        set {
        }
        get {
            return []
        }
    }

    var extentSettings: KernelOutputSizeSetting {
        return .none
    }

    var outputSize: KernelOutputSize {
        set {}
        get {
            return .inherit
        }
    }

    var extent: CGRect {
        return .zero
    }

    static var supportedArguments: [KernelArgumentType] {
        return []
    }

    static func initialSource(with _: String) -> String {
        return ""
    }

    var mockRequiredInputImages = 0
    var requiredInputImages: Int {
        return mockRequiredInputImages
    }

    var mockCompilerResult: KernelCompilerResult = .success(warnings: [])
    var compileCalled = false
    func compile(source _: String, completion: @escaping (KernelCompilerResult) -> Void) {
        completion(mockCompilerResult)
        compileCalled = true
    }

    func getImage() -> CIImage? {
        return nil
    }

    var renderCalled: Bool = false
    func render() {
        renderCalled = true
    }

    var outputView: KernelOutputView {
        return UIView()
    }

    var type: KernelType {
        return .coreimage
    }
}
