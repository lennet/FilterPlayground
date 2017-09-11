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

    var didUpdateText: ((String) -> Void)?
    var didUpdateArguments: (([(String, KernelAttributeType)]) -> Void)?

    var errors: [KernelError] = [] {
        didSet {
            guard errors != oldValue else { return }
            if errors.isEmpty {
                errorViewHeightConstraint.constant = 0
            } else {
                errorTableView.reloadData()
                errorTableView.layoutIfNeeded()
                errorViewHeightConstraint.constant = min(errorTableView.contentSize.height, view.frame.size.height / 4)
            }
            updateBottomSpacing(animated: true)
            textView.hightLightErrorLineNumber = []
        }
    }

    var fontSize: Float {
        get {
            return Settings.fontSize
        }

        set {
            Settings.fontSize = newValue
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
        updateFont()
        registerNotifications()
        textView.didUpdateArguments = { self.didUpdateArguments?($0) }
        textView.delegate = self

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gestureRecognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    func updateBottomSpacing(animated _: Bool) {
        bottomConstraint.constant = bottomSpacing
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.textView.setNeedsDisplay()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setNeedsDisplay()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return errors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCellIdentifier") as! ErrorTableViewCell
        // todo show notes
        cell.error = errors[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch errors[indexPath.row] {
        case .compile(lineNumber: let lineNumber, characterIndex: _, type: _, message: _, note: let note):
            var lineNumbers = [lineNumber]
            if let note = note {
                lineNumbers.append(note.lineNumber)
            }
            textView.hightLightErrorLineNumber = lineNumbers
            break
        case .runtime(message: _):
            break
        }
    }

    func updateFont() {
        textView.font = UIFont(name: "Menlo", size: CGFloat(fontSize))
        textView.setNeedsDisplay()
    }

    @objc func themeChanged(notification _: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.sourceEditorBackground
        textView.updatedText()
        textView.setNeedsDisplay()
    }

    func textViewDidChange(_ textView: UITextView) {
        didUpdateText?(textView.text)
    }

    func update(attributes: [KernelAttribute]) {
        textView.insert(arguments: attributes.map { ($0.name, $0.type) })
    }

    @objc func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        fontSize = (fontSize + Float(gestureRecognizer.velocity)/4)
        fontSize = max(fontSize, 9)
        fontSize = min(fontSize, 72)
    }
}
