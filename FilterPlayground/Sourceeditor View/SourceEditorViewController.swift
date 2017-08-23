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
    
    var didUpdateText: ((String)->())?
    
    var errors: [KernelError] = [] {
        didSet {
            guard errors != oldValue else { return }
            if errors.isEmpty {
                errorViewHeightConstraint.constant = 0
            } else {
                errorTableView.reloadData()
                errorTableView.layoutIfNeeded()
                errorViewHeightConstraint.constant = min(errorTableView.contentSize.height, view.frame.size.height/4)
            }
            updateBottomSpacing(animated: true)
            textView.hightLightErrorLineNumber = nil
        }
    }
    
    var fontSize: Float = 22 {
        didSet {
            updateFont()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
        textView.delegate = self
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setNeedsDisplay()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return errors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCellIdentifier") as! ErrorTableViewCell
        // todo show notes 
        switch errors[indexPath.row] {
        case .compile(lineNumber: _, characterIndex: _, type: let type, message: let message, note: _):
            cell.label.text = "\(type): \(message)"
            break
        case .runtime(message: let message):
            cell.label.text = "\(message)"
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch errors[indexPath.row] {
        case .compile(lineNumber: let lineNumber, characterIndex: _, type: _, message: _, note: _):
            textView.hightLightErrorLineNumber = lineNumber
            break
        case .runtime(message: _):
            break
        }

    }
    
    func updateFont() {
        textView.font = UIFont(name: "Menlo", size: CGFloat(fontSize))
        textView.setNeedsDisplay()
    }
    
    @objc func themeChanged(notification: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.sourceEditorBackground
        textView.renderText()
        textView.setNeedsDisplay()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        didUpdateText?(textView.text)
    }

}
