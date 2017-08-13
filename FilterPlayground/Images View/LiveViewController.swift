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
        return inputImageViews.flatMap{ $0.image }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
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
