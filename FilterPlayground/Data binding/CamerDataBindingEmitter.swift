//
//  CamerDataBindingEmitter.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import AVFoundation
import CoreMedia
import CoreImage
#if os(iOS) || os(tvOS)
    import UIKit
#endif

class CamerDataBindingEmitter: NSObject, DataBindingEmitter, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let shared: DataBindingEmitter = CamerDataBindingEmitter()
    let session = AVCaptureSession()
    let videoOrientation: AVCaptureVideoOrientation = {
        #if os(iOS) || os(tvOS)
            return AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        #else
            return AVCaptureVideoOrientation(rawValue: 0)!
        #endif
    }()

    private override init() {
        super.init()
        configureSession()
    }

    func configureSession() {
        #if os(iOS) || os(tvOS)
            let deviceDescoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                          mediaType: .video,
                                                                          position: .back)
            guard let device = deviceDescoverySession.devices.first else { return }
            // TODO: adjust framerate
            do {
                let input = try AVCaptureDeviceInput(device: device)
                session.addInput(input)
                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Camera Sample Buffer Delegate"))
                session.addOutput(output)
            } catch {
                // handle error
                print(error)
            }
        #endif
    }

    func activate() {
        session.startRunning()
    }

    func deactivate() {
        session.stopRunning()
    }

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = videoOrientation
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        DispatchQueue.main.async {
            DataBindingContext.shared.emit(value: CIImage(cvPixelBuffer: pixelBuffer), for: .camera)
        }
    }
}
