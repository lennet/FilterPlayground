//
//  SourceEditorViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var errorTableView: UITableView!
    @IBOutlet weak var textView: NumberedTextView!
    @IBOutlet weak var errorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat = 0.0
    
    var isShowingErrors: Bool {
        return !errors.isEmpty
    }
    
    var bottomSpacing: CGFloat {
        
        if isShowingErrors {
            return keyboardHeight + 8.0
        } else {
            return 0
        }
        
    }
    
    var errors: [CompilerError] = [] {
        didSet {
            guard errors != oldValue else { return }
            if errors.isEmpty {
                errorViewHeightConstraint.constant = 0
            } else {
                // todo check for keyboardsize
                
                errorViewHeightConstraint.constant = 100
            }
            updateBottomSpacing(animated: true)
            textView.hightLightErrorLineNumber = nil
            errorTableView.reloadData()
        }
    }
    
    var prefix: String = "vec 2 testFunc() {\n" {
        didSet {
            updateContent(editableSource: editableSource(with: oldValue))
        }
    }
    
    var fontSize: Float = 22 {
        didSet {
            textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize)).monospacedDigitFont
            textView.setNeedsDisplay()
        }
    }

    
    let postfix: String = "\n}"
    
    var source: String {
        get {
            return textView.text ?? ""
        }
        set {
            textView.text = newValue
        }
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
        textView.setNeedsDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SourceEditorViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SourceEditorViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }

    func updateBottomSpacing(animated: Bool) {
        bottomConstraint.constant = bottomSpacing
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.textView.setNeedsDisplay()
        }
     }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardHeight = keyboardSize.height
        updateBottomSpacing(animated: true)
    }
        
    @objc func keyboardWillHide(notification: Notification) {
        keyboardHeight = 0
        updateBottomSpacing(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return errors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCellIdentifier") as! ErrorTableViewCell
        let error = errors[indexPath.row]
        cell.label.text = "\(error.type): \(error.message)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let error = errors[indexPath.row]
        textView.hightLightErrorLineNumber = error.lineNumber
    }
}
