//
//  SelectImageView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import MobileCoreServices

class CustomImageView: UIImageView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDropInteractionDelegate, UIDragInteractionDelegate {

    var didSelectImage: ((CustomImageView) -> Void)?
    var canSelectImage = true

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
        guard canSelectImage else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = self
        imagePicker.popoverPresentationController?.sourceRect = frame

        window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        self.image = image
        didSelectImage?(self)
    }

    func dropInteraction(_: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return canSelectImage && session.canLoadObjects(ofClass: UIImage.self)
    }

    func dropInteraction(_: UIDropInteraction, sessionDidUpdate _: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_: UIDropInteraction, sessionDidEnter _: UIDropSession) {
        layer.borderWidth = 2
        layer.borderColor = ThemeManager.shared.currentTheme.dropInteractionBorder.cgColor
    }

    func dropInteraction(_: UIDropInteraction, sessionDidExit _: UIDropSession) {
        layer.borderWidth = 0
    }

    func dropInteraction(_: UIDropInteraction, sessionDidEnd _: UIDropSession) {
        layer.borderWidth = 0
    }

    func dropInteraction(_: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [weak self] imageItems in
            guard let images = imageItems as? [UIImage] else { return }
            self?.image = images.first
            self?.didSelectImage?(self!)
        }
    }

    func dragInteraction(_: UIDragInteraction, itemsForBeginning _: UIDragSession) -> [UIDragItem] {
        guard let image = image else {
            return []
        }
        let item: UIImage
        if let ciImage = image.ciImage {
            // ciimage bases images are empty after dropping
            let context = CIContext()
            item = UIImage(cgImage: context.createCGImage(ciImage, from: ciImage.extent)!)
        } else {
            item = image
        }

        let imageItemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: imageItemProvider)
        dragItem.previewProvider = {
            UIDragPreview(view: UIImageView(image: image))
        }
        return [dragItem]
    }
}
