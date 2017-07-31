//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import SafariServices

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
    @IBAction func documentation(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CIKernelLangRef/ci_gslang_ext.html")!
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        safariVC.popoverPresentationController?.barButtonItem = sender
        
        present(safariVC, animated: true, completion: nil)
        
    }
    
    @IBAction func run() {
        guard !isRunning else { return }
        defer {
            isRunning = false
        }
        
        guard let source = sourceEditorViewController?.source,
            let image = imagesViewController?.inputImage,
            let descriptor = attributesViewController?.kernelDescriptor,
            let input = CIImage(image: image) else {
                return
        }
        let errorHelper = ErrorHelper()
        guard let kernel = CIWarpKernel(source: source) else {
            let alert = UIAlertController(title: "Error", message: errorHelper.parseError(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let filtred = kernel.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, image: input, arguments: descriptor.attributes.flatMap{ $0.value }) else {
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

