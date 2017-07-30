//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var attributesViewController: AttributesViewController? {
        didSet {
            attributesViewController?.didUpdateDescriptor = didUpdate
        }
    }
    weak var imagesViewController: ImageViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    var isRunning = false
        
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
        
        let increaseFontKeyCommand = UIKeyCommand(input: "+", modifierFlags: .command, action: #selector(increaseFontSize), discoverabilityTitle: "increase font size")
        
        let decreaseFontKeyCommand = UIKeyCommand(input: "-", modifierFlags: .command, action: #selector(decreaseFontSize), discoverabilityTitle: "decrease font size")

        
        return[ runKeyCommand, increaseFontKeyCommand, decreaseFontKeyCommand ]
    }
    
    @objc func increaseFontSize() {
        sourceEditorViewController?.fontSize += 3
    }
    
    @objc func decreaseFontSize() {
        sourceEditorViewController?.fontSize -= 3
    }
    
    func didUpdate(descriptor: KernelDescriptor, shouldRun: Bool) {
        sourceEditorViewController?.prefix = descriptor.prefix
        
        if shouldRun {
            run()
        }
    }
    
    @objc func run() {
        guard !isRunning else { return }
        isRunning = true
        guard let source = sourceEditorViewController?.source,
            let image = imagesViewController?.inputImage,
            let descriptor = attributesViewController?.kernelDescriptor,
            let input = CIImage(image: image) else {
                isRunning = false
                return
        }
        
        
        let kernel = CIWarpKernel(source: source)
        guard let filtred = kernel?.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, image: input, arguments: descriptor.attributes.flatMap{ $0.value }) else {
            isRunning = false
            return
        }
        
        
        let result = UIImage(ciImage: filtred)
        imagesViewController?.outputImage = result
        isRunning = false
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

