//
//  ImageViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet private weak var inputImageView: SelectImageView!
    @IBOutlet private weak var outputImageView: UIImageView!
    
    public var inputImage: UIImage? {
        get {
            return inputImageView.image
        }
    }
    
    public var outputImage: UIImage? {
        get {
            return outputImageView.image
        }
        set {
            outputImageView.image = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        inputImageView.didSelectImage = { [weak self] _ in
            self?.outputImageView.image = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
