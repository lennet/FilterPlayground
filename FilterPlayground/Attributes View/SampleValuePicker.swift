//
//  SampleValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SampleValuePicker: UIView, KernelArgumentValueView {

    var updatedValueCallback: ((KernelArgumentValue) -> Void)?
    var value: KernelArgumentValue {
        didSet {
            if case let .sample(i) = value {
                imageView.image = i.asImage
            }
        }
    }

    weak var imageView: CustomImageView!

    required init?(frame: CGRect, value: KernelArgumentValue) {
        self.value = value
        super.init(frame: frame)
        var image: UIImage?
        if case let .sample(i) = value {
            image = i.asImage
        }
        let imageView = CustomImageView(image: image)
        imageView.frame = bounds
        imageView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        imageView.didSelectImage = updated
        addSubview(imageView)
        self.imageView = imageView
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updated(imageView: CustomImageView) {
        guard let newImage = imageView.image?.asCIImage else { return }
        value = .sample(newImage)
        updatedValueCallback?(value)
    }
}
