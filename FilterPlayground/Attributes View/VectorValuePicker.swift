//
//  VectorValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 16.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class VectorValuePicker: UIControl, UIPopoverPresentationControllerDelegate {
    
    var poppoverControllerPresentationController: UIPopoverPresentationController?
    var floatPicker: SelectFloatViewController?
    var currentHighlightedIndex: UInt = 0
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()
    
    init(frame: CGRect, numberOfValues: UInt) {
        super.init(frame: frame)
        
        stackView.frame = bounds
        addSubview(stackView)
        
        (1...numberOfValues).forEach(addFloatPicker)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addFloatPicker(index: UInt){
        let label = UILabel()
        label.frame.size.width = bounds.width
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.text = "0.0"
        stackView.addArrangedSubview(label)
    }
    
    @objc func handleTap() {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "SelectFloatViewControllerIdentifier") as! SelectFloatViewController
        self.floatPicker = viewController
        viewController.valueChanged = { value in
            self.highlight(at: 2)
        }
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self
        viewController.popoverPresentationController?.delegate = self
        self.poppoverControllerPresentationController = viewController.popoverPresentationController
        
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(viewController, animated: true, completion: nil)
        highlight(at: 1)
    }
    
    func highlight(at index: UInt) {
        guard currentHighlightedIndex != index else {
            return
        }
        currentHighlightedIndex = index
        stackView.arrangedSubviews.enumerated().forEach { (i, view) in
            guard let label = view as? UILabel else {
                return
            }
            if index == i+1 {
                label.textColor = .blue
                
                // todo fix updating sourcerect
                self.poppoverControllerPresentationController?.sourceView = label
                self.poppoverControllerPresentationController?.sourceRect = label.bounds
            } else {
                label.textColor = .black
            }
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        highlight(at: 0)
    }
    
}
