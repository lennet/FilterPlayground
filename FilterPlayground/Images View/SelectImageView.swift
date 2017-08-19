//
//  SelectImageView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import MobileCoreServices

class SelectImageView: UIImageView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    var didSelectImage: ((SelectImageView)->())?

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true
        
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
        
        let dragInteraction = UIDragInteraction(delegate: self)
        addInteraction(dragInteraction)
    }
    
    @objc func handleTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = self
        imagePicker.popoverPresentationController?.sourceRect = frame
        
        self.window?.rootViewController?.presentedViewController?.present(imagePicker, animated: true, completion: nil)
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
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            let images = imageItems as! [UIImage]
            self.image = images.first
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = image else {
            return []
        }
        let imageItemProvider =  NSItemProvider(object: image)
        return [ UIDragItem(itemProvider: imageItemProvider) ]
    }

}
