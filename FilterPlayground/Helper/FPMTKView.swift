//
//  FPMTKView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 13.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import MetalKit
import Metal

class FPMTKView: MTKView {

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
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
