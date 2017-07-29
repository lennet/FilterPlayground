//
//  SelectImageView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import MobileCoreServices

class SelectImageView: UIImageView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didSelectImage: ((SelectImageView)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true
    }
    
    @objc func handleTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = self
        var sourceRect = frame
        sourceRect.origin.y -= 30
        imagePicker.popoverPresentationController?.sourceRect = sourceRect
        
        self.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        self.image = image
        didSelectImage?(self)
    }
}
