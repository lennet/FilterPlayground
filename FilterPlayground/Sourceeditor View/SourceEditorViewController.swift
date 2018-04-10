//
//  SourceEditorViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SourceEditorViewController: UIViewController, UITextViewDelegate, Identifiable {
    @IBOutlet var textView: NumberedTextView!
    @IBOutlet var errorViewHeightConstraint: NSLayoutConstraint!

    weak var errorViewController: ErrorViewController?

    var isShowingErrors: Bool {
        return !errors.isEmpty
    }

    var didUpdateText: ((String) -> Void)?
    var didUpdateArguments: (([KernelDefinitionArgument]) -> Void)?

    var errors: [KernelError] {
        set {
            errorViewController?.errors = newValue
            textView.highLightErrorLineNumber = []
        }
        get {
            return errorViewController?.errors ?? []
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setNeedsDisplay()
    }

    func updateFont() {
        textView.font = UIFont(name: "Menlo", size: CGFloat(fontSize))!
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

    func update(attributes: [KernelArgument]) {
        textView.insert(arguments: attributes.map(KernelDefinitionArgument.init))
    }

    @objc func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        fontSize = (fontSize + Float(gestureRecognizer.velocity) / 4)
        fontSize = max(fontSize, 9)
        fontSize = min(fontSize, 72)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let errorViewController = segue.destination as? ErrorViewController {
            errorViewController.shouldHighLight = { lineNumbers in
                self.textView.highLightErrorLineNumber = lineNumbers
            }
            errorViewController.shouldUpdateHeight = { height, animated in
                self.errorViewHeightConstraint.constant = height

                UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            self.errorViewController = errorViewController
        }
    }
}
