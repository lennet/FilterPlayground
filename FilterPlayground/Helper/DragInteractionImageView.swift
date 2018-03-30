//
//  DragInteractionImageView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import AVFoundation
import UIKit

// Images with a high resolution sometimes are displayed as blank images during drag interactions
// This helper class downscales large images
class DragInteractionImageView: UIImageView {
    let maxRect = CGRect(origin: .zero, size: CGSize(width: 250, height: 250))
    init(image: UIImage) {
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: maxRect)
        super.init(frame: CGRect(origin: .zero, size: rect.size))
        self.image = image
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
