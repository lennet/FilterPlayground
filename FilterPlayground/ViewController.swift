//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var attributesViewController: AttributesViewController?
    weak var imagesViewController: ImageViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {

        let runKeyCommand = UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(run), discoverabilityTitle: "Run")
        
        return[ runKeyCommand ]
    }
    
    @objc func run() {
        guard let source = sourceEditorViewController?.source,
            let image = imagesViewController?.inputImage,
            let input = CIImage(image: image) else {
            return
        }
        let kernel = CIWarpKernel(source: source)
        guard let filtred = kernel?.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, image: input, arguments: []) else {
            return
        }
        
        let result = UIImage(ciImage: filtred)
        imagesViewController?.outputImage = result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as AttributesViewController:
            self.attributesViewController = vc
        case let vc as ImageViewController:
            self.imagesViewController = vc
        case let vc as SourceEditorViewController:
            self.sourceEditorViewController = vc
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }
}

