//
//  FPMTKView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 13.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import MetalKit

class FPMTKView: MTKView {
    
    var needsDisplay = false
    var timer: Timer?

    convenience init(device: MTLDevice?, delegate: MTKViewDelegate) {
        self.init(frame: .zero, device: device)
        self.delegate = delegate
        enableSetNeedsDisplay = true
        #if os(iOS) || os(tvOS)
            contentMode = .scaleAspectFit
            contentScaleFactor = UIScreen.main.scale
        #endif
        autoResizeDrawable = false
        framebufferOnly = false
    }

    private override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        NotificationCenter.default.addObserver(self, selector: #selector(frameRateChanged), name: FrameRateManager.frameRateChangedNotificationName, object: nil)
        activateTimer()
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsDisplay() {
        needsDisplay = true
    }
    
    func activateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: FrameRateManager.shared.frameInterval, repeats: true, block: didUpdate)
        timer?.fire()
    }
    
    func deactivateTimer() {
        timer?.invalidate()
    }
    
    func didUpdate(timer _: Timer) {
        guard needsDisplay else { return }
        needsDisplay = false
        super.setNeedsDisplay()
    }
    
    @objc func frameRateChanged() {
        deactivateTimer()
        activateTimer()
    }

}
