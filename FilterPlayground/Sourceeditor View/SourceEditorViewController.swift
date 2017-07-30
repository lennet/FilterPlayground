//
//  SourceEditorViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: NumberedTextView!
    
    var prefix: String = "vec 2 testFunc() {\n" {
        didSet {
            updateContent(editableSource: editableSource(with: oldValue))
        }
    }
    
    let postfix: String = "\n}"
    
    var source: String {
        return textView.text ?? ""
    }
    
    func editableSource(with prefix: String) -> String {
        var result = source
        if let prefixRange = result.range(of: prefix) {
            result.removeSubrange(prefixRange)
        }
        
        if let postfixRange = result.range(of: postfix) {
            result.removeSubrange(postfixRange)
        }
        
        return result
    }
    
    func updateContent(editableSource: String) {
        let fullSource = "\(prefix) \(editableSource) \(postfix)"
        textView.text = fullSource
        textView.setNeedsLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
