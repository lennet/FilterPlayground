//
//  MetalKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import MetalKit

class MetalKernel: NSObject, Kernel, MTKViewDelegate {
    var type: KernelType {
        return .metal
    }

    var extentSettings: KernelOutputSizeSetting {
        return .sizeOnly
    }

    var extent: CGRect {
        switch outputSize {
        case .inherit:
            if let inputTexture = inputTextures.first {
                return CGRect(origin: .zero, size: CGSize(width: inputTexture.width, height: inputTexture.height))
            }
            return CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000))
        case let .custom(value):
            return value
        }
    }

    var outputSize: KernelOutputSize = .inherit {
        didSet {
            mtkView.drawableSize = extent.size
        }
    }

    var inputImages: [CIImage] = []

    var mtkView: FPMTKView!

    var outputView: KernelOutputView {
        return mtkView
    }

    var arguments: [KernelArgument] = [] {
        didSet {
            makeInputTextures()
        }
    }

    let threadGroupCount = MTLSizeMake(16, 16, 1)
    let device: MTLDevice?
    let commandQueue: MTLCommandQueue?
    var pipelineState: MTLComputePipelineState?
    var library: MTLLibrary?
    var inputTextures: [MTLTexture] = []
    var context: CIContext?
    var function: MTLFunction? {
        didSet {
            guard let function = function else {
                return
            }

            device?.makeComputePipelineState(function: function, completionHandler: { state, error in
                self.pipelineState = state
                print(error ?? "")
            })
        }
    }

    required override init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()
        #if !(targetEnvironment(simulator))
            context = CIContext(mtlDevice: device!)
        #else
            context = CIContext()
        #endif
        super.init()
        mtkView = FPMTKView(device: device, delegate: self)
    }

    var requiredInputImages: Int {
        return 0
    }

    static var supportedArguments: [KernelArgumentType] {
        // TODO:
        return [.float, .vec2, .vec3, .vec4]
    }

    func render() {
        if function == nil {
            makeFunction()
        }
        mtkView.setNeedsDisplay()
    }

    func getImage() -> CIImage? {
        // TODO:
        return nil
    }

    func didUpdateInputImages() {
        makeInputTextures()
        makeFunction()
    }

    func makeInputTextures() {
        // TODO: use CIContext to render image into texture
        guard let device = device else { return }
        inputTextures = arguments.compactMap { (argument) -> CIImage? in
            switch (argument.access, argument.value) {
            case let (.read, .sample(image)):
                return image
            default:
                return nil
            }
        }.compactMap { (image) -> MTLTexture? in

            guard let cgImage = context?.createCGImage(image, from: image.extent) else { return nil }

            let textureLoader = MTKTextureLoader(device: device)

            do {
                return try textureLoader.newTexture(cgImage: cgImage, options: nil)
            } catch {
                print(error)
                if let data = image.asJPGData {
                    return try? textureLoader.newTexture(data: data, options: nil)
                }
                return nil
            }
        }
    }

    func makeFunction() {
        guard let lib = library else { return }
        guard let functionName = lib.functionNames.first else { return }
        let constantValues = MTLFunctionConstantValues()
        lib.makeFunction(name: functionName, constantValues: constantValues) { function, _ in
            // TODO: handle error

            self.function = function
            DispatchQueue.main.async {
                self.mtkView.setNeedsDisplay()
            }
        }
    }

    func compile(source: String, completion: @escaping (KernelCompilerResult) -> Void) {
        var errors: [KernelError] = []

        device?.makeLibrary(source: source, options: nil, completionHandler: { lib, error in

            self.library = lib
            if let error = error as? MTLLibraryError {
                errors = MetalErrorParser.compileErrors(for: error.localizedDescription)
                print(error)
            }
            if self.library == nil {
                completion(.failed(errors: errors))
            } else {
                // TODO: wait for makeFunction
                self.makeFunction()
                completion(.success(warnings: errors))
            }
        })
    }

    static func initialSource(with name: String) -> String {
        return """
        #include <metal_stdlib>
        using namespace metal;
        
        kernel void \(name)(
        texture2d<float, access::read> inTexture [[texture(0)]],
        texture2d<float, access::write> outTexture [[texture(1)]],
        uint2 gid [[thread_position_in_grid]])
        {
            outTexture.write(inTexture.read(gid), gid);
        }
        """
    }

    // Mark: - MTKViewDelegate

    func draw(in view: MTKView) {
        if let currentDrawable = view.currentDrawable,
            let pipelineState = pipelineState {
            let commandBuffer = commandQueue?.makeCommandBuffer()

            let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
            commandEncoder?.setComputePipelineState(pipelineState)
            inputTextures.enumerated().forEach({ index, texture in
                commandEncoder?.setTexture(texture, index: index)
            })
            #if !(targetEnvironment(simulator))
                commandEncoder?.setTexture(currentDrawable.texture, index: inputTextures.count)
            #endif

            mtkView.drawableSize = extent.size
            var index = 0
            arguments
                .filter({ (argument) -> Bool in
                    if case .buffer = argument.origin {
                        return true
                    }
                    return false
                })
                .forEach({ argument in
                    argument.value.withUnsafeMetalBufferValue({ (pointer, length) -> Void in
                        commandEncoder?.setBytes(pointer, length: length, index: index)
                        index += 1
                    })
                })

            let threadGroups = MTLSize(width: Int(extent.width) / threadGroupCount.width, height: Int(extent.height) / threadGroupCount.height, depth: 1)

            commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder?.endEncoding()
            commandBuffer?.addCompletedHandler(bufferCompletionHandler)
            commandBuffer?.present(currentDrawable)
            commandBuffer?.commit()
        }
    }

    func bufferCompletionHandler(buffer: MTLCommandBuffer) {
        if let error = buffer.error {
            print(error.localizedDescription)
        }

        mtkView.bufferCompletionHandler(buffer: buffer)
    }

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
        mtkView.setNeedsDisplay()
    }
}
