//
//  MetalKernel.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreImage
import Metal
import MetalKit

class MetalKernel: NSObject, Kernel, MTKViewDelegate {

    var inputImages: [CIImage] = [] {
        didSet {
            didUpdateInputImages()
        }
    }

    var mtkView: MTKView!

    var outputView: KernelOutputView {
        return mtkView
    }

    var arguments: [KernelAttributeValue] = []

    let threadGroupCount = MTLSizeMake(16, 16, 1)
    let device: MTLDevice?
    let commandQueue: MTLCommandQueue?
    var pipelineState: MTLComputePipelineState?
    var library: MTLLibrary?
    var inputTexture: MTLTexture?
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
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            context = CIContext(mtlDevice: device!)
        #else
            context = CIContext()
        #endif
        super.init()
        mtkView = FPMTKView(device: device, delegate: self)
    }

    static var requiredInputImages: Int {
        return 1
    }

    static var supportedArguments: [KernelArgumentType] {
        // todo
        return [.float]
    }

    var shadingLanguage: ShadingLanguage {
        return .metal
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
        makeInputTexture()
        makeFunction()
    }
    
    func makeInputTexture() {
        // todo use CIContext to render image into texture
        guard let device = device else { return }
        guard let image = inputImages.first else { return }
        guard let cgImage = context?.createCGImage(image, from: image.extent) else { return }
        
        let textureLoader = MTKTextureLoader(device: device)
        do {
            self.inputTexture = try textureLoader.newTexture(cgImage: cgImage, options: nil)
            if let texture = self.inputTexture {
                self.mtkView.drawableSize = CGSize(width: texture.width, height: texture.height)
            }
        } catch {
            print(error)
        }
    }

    func makeFunction() {
        guard let lib = library else { return }
        guard let functionName = lib.functionNames.first else { return }
        let constantValues = MTLFunctionConstantValues()
        lib.makeFunction(name: functionName, constantValues: constantValues) { function, error in
            // todo handle error

            self.function = function
            
            self.mtkView.setNeedsDisplay()
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
                completion(.success(errors: errors))
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
        
        
        }
        """
    }

    // Mark: - MTKViewDelegate

    func draw(in view: MTKView) {
        if let currentDrawable = view.currentDrawable,
            let inputTexture = inputTexture,
            let pipelineState = pipelineState {
            let commandBuffer = commandQueue?.makeCommandBuffer()

            let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
            commandEncoder?.setComputePipelineState(pipelineState)
            commandEncoder?.setTexture(inputTexture, index: 0)
            #if !((arch(i386) || arch(x86_64)) && os(iOS))
                commandEncoder?.setTexture(currentDrawable.texture, index: 1)
            #endif

            var index = 0
            arguments.forEach({ value in
                value.withUnsafeMetalBufferValue({ (pointer, length) -> Void in
                    commandEncoder?.setBytes(pointer, length: length, index: index)
                    index += 1
                })
            })

            let threadGroups = MTLSize(width: Int(inputTexture.width) / threadGroupCount.width, height: Int(inputTexture.height) / threadGroupCount.height, depth: 1)

            commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder?.endEncoding()

            commandBuffer?.present(currentDrawable)
            commandBuffer?.commit()
        }
    }

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
        mtkView.setNeedsDisplay()
    }
}
