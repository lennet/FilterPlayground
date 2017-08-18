//
//  LiveViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {
    
    @IBOutlet weak var imageView: SelectImageView!
    @IBOutlet var inputImageViews: [SelectImageView]!
    
    var didUpdateInputImages: (([UIImage]) -> ())?
    
    var numberOfInputs: Int = 2 {
        didSet {
            switch numberOfInputs {
            case 2:
                inputImageViews.forEach { $0.isHidden = false }
                inputImageViews.first?.superview?.isHidden = false
                break
            case 1:
                inputImageViews.first?.superview?.isHidden = false
                inputImageViews.last?.isHidden = true
                break
            default:
                inputImageViews.first?.superview?.isHidden = true
                break
            }
        }
    }
    
    var inputImages: [UIImage] {
        get {
            return inputImageViews.flatMap{ $0.image }
        }
        set {
            for (index, image) in newValue.enumerated() where index < inputImageViews.count {
                inputImageViews[index].image = image
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputImageViews.forEach{ $0.accessibilityIgnoresInvertColors = true }
        inputImageViews.forEach{ $0.didSelectImage = didSelectImage }
        imageView.accessibilityIgnoresInvertColors = true
    }
    
    func didSelectImage(imageView: SelectImageView){
        didUpdateInputImages?(inputImages)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func reset() {
        imageView.image = nil
        inputImageViews.forEach{ $0.image = nil }
    }
    
    @objc func themeChanged(notification: Notification?) {
        self.view.backgroundColor = ThemeManager.shared.currentTheme.liveViewBackground
    }
    
}
